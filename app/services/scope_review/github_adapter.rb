module ScopeReview
  # GitHub-specific signals: the API pre-flight (repo size before cloning,
  # authoritative license, default branch), the engagement block, and
  # sibling-repo discovery. Everything here is read-only.
  #
  # Non-GitHub hosts have no adapter (yet): their engagement block is
  # {available: false} and every dependent gate treats those fields as
  # UNKNOWN — missing is never zero. A GitLab/Bitbucket adapter can implement
  # the same three methods if that host volume ever warrants it.
  class GithubAdapter
    BOT_LOGIN_RE = /\[bot\]\z|\A(dependabot|github-actions|renovate|codecov|pre-commit-ci)\b/i
    ENGAGEMENT_SAMPLE = 100

    def self.for(repo_url)
      m = repo_url.to_s.match(%r{github\.com[/:]([^/\s]+)/([^/\s]+?)(?:\.git)?/?\z}i)
      m ? new(m[1], m[2]) : nil
    end

    attr_reader :owner, :repo

    def initialize(owner, repo)
      @owner = owner
      @repo = repo
    end

    def nwo
      "#{owner}/#{repo}"
    end

    # Cheap single REST call made BEFORE cloning: size (KB) gates the clone,
    # license/default_branch feed RepoInfo.
    def preflight
      data = client.repository(nwo)
      {
        size_kb: data.size,
        default_branch: data.default_branch,
        license_spdx: data.license&.spdx_id,
        archived: data.archived,
        fork: data.fork,
        pushed_at: data.pushed_at&.iso8601,
      }
    rescue Octokit::Error => e
      { error: e.class.name }
    end

    # Engagement metrics via one GraphQL call. Issues/PRs are sampled (first
    # #{ENGAGEMENT_SAMPLE}) so unique_participants is a lower bound on busy
    # repos — `sampled` records that.
    def engagement
      data = graphql(ENGAGEMENT_QUERY, owner: owner, name: repo)
      repo_data = data&.dig("data", "repository")
      return { available: false } unless repo_data

      issues = repo_data.dig("issues", "nodes") || []
      prs = repo_data.dig("pullRequests", "nodes") || []
      issue_count = repo_data.dig("issues", "totalCount").to_i
      pr_count = repo_data.dig("pullRequests", "totalCount").to_i

      {
        available: true,
        unique_participants: unique_participants(issues + prs),
        issue_count: issue_count,
        pr_count: pr_count,
        contributor_count: contributor_count,
        release_count: repo_data.dig("releases", "totalCount").to_i,
        stars: repo_data["stargazerCount"].to_i,
        forks: repo_data["forkCount"].to_i,
        sampled: issue_count > ENGAGEMENT_SAMPLE || pr_count > ENGAGEMENT_SAMPLE,
      }
    rescue Octokit::Error
      { available: false }
    end

    # Repositories under the same owner whose names look related to the
    # submission — the split backend/CLI pattern (FAIVOR's ML-Validator,
    # Olmsted's CLI living in a second repo).
    def sibling_repos
      data = graphql(SIBLINGS_QUERY, owner: owner)
      nodes = data&.dig("data", "repositoryOwner", "repositories", "nodes") || []
      target_tokens = name_tokens(repo)

      nodes.filter_map do |node|
        name = node["name"]
        next if name.casecmp?(repo)

        related = name_tokens(name).intersect?(target_tokens) ||
                  name.downcase.include?(repo.downcase) || repo.downcase.include?(name.downcase) ||
                  node["description"].to_s.downcase.include?(repo.downcase)
        next unless related

        { name: name, description: node["description"].to_s[0, 200], fork: node["isFork"] }
      end.first(10)
    rescue Octokit::Error
      []
    end

    private

    # Own client: the global GITHUB has auto_paginate on, which would turn
    # count-only queries into full crawls.
    def client
      @client ||= Octokit::Client.new(access_token: ENV["GH_TOKEN"], auto_paginate: false)
    end

    def graphql(query, variables)
      response = client.post("/graphql", { query: query, variables: variables }.to_json)
      JSON.parse(response.to_attrs.to_json)
    end

    # "External participants" must be humans other than the maintainer:
    # bot-authored items (dependabot PRs etc.) are not community engagement,
    # and neither is the repo owner replying on their own repository.
    def unique_participants(items)
      participants = Set.new
      items.each do |item|
        author = item.dig("author", "login")
        next if author.present? && author.match?(BOT_LOGIN_RE)

        (item.dig("participants", "nodes") || []).each do |p|
          login = p["login"]
          next if login.blank? || login == author || login.match?(BOT_LOGIN_RE)
          next if login.casecmp?(owner)

          participants << login
        end
      end
      participants.size
    end

    # Standard trick: per_page=1, contributor count = number of the last page.
    def contributor_count
      client.contributors(nwo, nil, per_page: 1)
      last = client.last_response.rels[:last]
      last ? Integer(URI.decode_www_form(URI(last.href).query).to_h["page"]) : client.last_response.data.length
    rescue Octokit::Error, ArgumentError, TypeError
      nil
    end

    def name_tokens(name)
      name.downcase.split(/[-_.\s]+/).select { |t| t.length >= 3 }.to_set
    end

    ENGAGEMENT_QUERY = <<~GRAPHQL
      query($owner: String!, $name: String!) {
        repository(owner: $owner, name: $name) {
          stargazerCount
          forkCount
          releases { totalCount }
          issues(first: #{ENGAGEMENT_SAMPLE}, states: [OPEN, CLOSED]) {
            totalCount
            nodes { author { login } participants(first: 20) { nodes { login } } }
          }
          pullRequests(first: #{ENGAGEMENT_SAMPLE}, states: [OPEN, CLOSED, MERGED]) {
            totalCount
            nodes { author { login } participants(first: 20) { nodes { login } } }
          }
        }
      }
    GRAPHQL

    SIBLINGS_QUERY = <<~GRAPHQL
      query($owner: String!) {
        repositoryOwner(login: $owner) {
          repositories(first: 100, orderBy: {field: PUSHED_AT, direction: DESC}, ownerAffiliations: OWNER) {
            nodes { name description isFork }
          }
        }
      }
    GRAPHQL
  end
end
