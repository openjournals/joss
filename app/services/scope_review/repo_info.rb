module ScopeReview
  # Assembles the L0 signal blob (the ported gh-action-repo-checks output plus
  # the additions that close its blind spots: path-scoped ages, data-vs-code
  # window classification, test detection, merged author identities, bib
  # authors, sibling repos). Pure computation — no model calls, no writes.
  #
  # Every section is independently fault-tolerant: a failure in one signal is
  # recorded in :errors and leaves that field nil/unknown rather than sinking
  # the whole assessment. Downstream, nil/unknown always escalates to a human;
  # it never counts as a failure.
  class RepoInfo
    def self.build(dir:, repo_url:, host_data: {}, adapter: nil)
      new(dir: dir, repo_url: repo_url, host_data: host_data, adapter: adapter).to_h
    end

    # The paper's full text is needed in-memory for the L2/L3 prompts but is
    # deliberately NOT part of the persisted blob.
    attr_reader :paper_content

    def initialize(dir:, repo_url:, host_data: {}, adapter: nil)
      @dir = dir
      @repo_url = repo_url
      @host_data = host_data || {}
      @adapter = adapter
      @errors = []
    end

    def to_h
      @to_h ||= compute
    end

    private

    def compute
      history = section(:git_history) { GitHistory.new(@dir) }
      stats = section(:language_stats) { LanguageStats.new(@dir) }
      paths = stats&.relative_paths || []
      paper = section(:paper) { PaperSignals.new(@dir, paths) }
      @paper_content = paper&.content

      {
        repo_url: @repo_url,
        host: host,
        computed_at: Time.now.utc.iso8601,

        # --- clone-based: available on any git host ---
        head_sha: history&.head_sha,
        commit_count: history&.commit_count,
        history_truncated: history ? history.commit_count > history.commit_cap : nil,
        first_commit: section(:first_commit) { history&.first_commit },
        path_scoped_age: path_scoped_age(history, stats, paper),
        code_windows: section(:code_windows) { history&.code_windows } || [],
        languages: section(:languages) { stats&.to_h },
        authors: section(:authors) { history&.authors } || [],
        authors_merged: section(:authors_merged) { history&.merged_authors&.length },
        authors_merged_list: section(:authors_merged_list) { history&.merged_authors } || [],
        tags_count: section(:tags) { history&.tags_count },
        tests: section(:tests) { TestSignals.new(@dir, paths).to_h },
        license: section(:license) { LicenseDetector.detect(@dir, paths, host_spdx: @host_data[:license_spdx]) },
        community_files: community_files(paths),
        paper: paper_block(paper, history),

        # --- host-API-based: tri-state, unknown on hosts without an adapter ---
        host_meta: @host_data.slice(:archived, :fork, :pushed_at, :size_kb, :default_branch),
        engagement: section(:engagement) { @adapter ? @adapter.engagement : { available: false } },
        sibling_repos: section(:sibling_repos) { @adapter ? @adapter.sibling_repos : [] } || [],

        errors: @errors,
      }
    end

    def host
      case @repo_url
      when %r{github\.com}i then "github"
      when %r{gitlab}i then "gitlab"
      when %r{bitbucket\.org}i then "bitbucket"
      else "other"
      end
    end

    # The spec's highest-value addition: first-commit dates scoped to where
    # the paper and the primary source directory live. A big gap between
    # these and the whole-repo first commit is the repurposed-repo /
    # new-module trigger (FlashSpec, 3W, citrees).
    def path_scoped_age(history, stats, paper)
      return {} unless history

      section(:path_scoped_age) do
        src_dir = stats&.primary_src_dir
        {
          paper_dir: scoped_entry(history, paper&.paper_dir || paper&.path),
          primary_src_dir: scoped_entry(history, src_dir),
        }
      end || {}
    end

    def scoped_entry(history, path)
      return nil if path.blank?

      first = history.first_commit_for_path(path)
      first ? first.merge(path: path) : nil
    end

    def paper_block(paper, history)
      return { found: false } unless paper

      section(:paper_block) do
        block = paper.to_h
        if paper.found? && history
          last = history.last_commit_for_path(paper.path)
          block[:last_commit_timestamp] = last&.dig(:timestamp)
        end
        block
      end || { found: false }
    end

    def community_files(paths)
      top_level = paths.select { |p| p.count("/") <= 1 }
      {
        contributing: top_level.any? { |p| File.basename(p).match?(/\Acontributing(\.|$)/i) },
        code_of_conduct: top_level.any? { |p| File.basename(p).match?(/\Acode[-_]of[-_]conduct(\.|$)/i) },
        changelog: top_level.any? { |p| File.basename(p).match?(/\A(changelog|news|history)(\.|$)/i) },
        readme: top_level.any? { |p| File.basename(p).match?(/\Areadme(\.|$)/i) },
        citation: paths.any? { |p| p.match?(/\A(citation\.cff|\.zenodo\.json|codemeta\.json)\z/i) },
        docs_dir: paths.any? { |p| p.match?(%r{\Adocs?/}i) },
      }
    end

    def section(name)
      yield
    rescue StandardError => e
      @errors << { section: name.to_s, error: "#{e.class}: #{e.message.to_s[0, 200]}" }
      nil
    end
  end
end
