require "open3"

module ScopeReview
  # Commit-history signals from a full clone, computed with plain `git`
  # commands. Ports the gh-action-repo-checks logic (first commit date, 48h
  # insertion-window "repo dump" detection) with two additions the action
  # lacks: per-window code-vs-data classification, and first-commit dates
  # scoped to a path (catches code dumped into an old, repurposed repo).
  #
  # The whole history is read in ONE `git log --numstat` pass — O(history)
  # once, not per-commit diffs.
  class GitHistory
    class GitError < StandardError; end

    WINDOW_SECONDS = 48 * 60 * 60
    SIGNAL_LEVELS = [[75, "critical"], [50, "strong"], [25, "moderate"], [0, "healthy"]].freeze
    DATA_WINDOW_THRESHOLD = 0.5

    attr_reader :commit_cap

    def initialize(dir, commit_cap: nil)
      @dir = dir
      @commit_cap = commit_cap || ScopeReview.config(:history_commit_cap, 5000)
    end

    def to_h
      {
        head_sha: head_sha,
        commit_count: commit_count,
        history_truncated: commit_count > commit_cap,
        first_commit: first_commit,
        code_windows: code_windows,
        authors: authors,
        authors_merged: merged_authors.length,
        authors_merged_list: merged_authors,
        tags_count: tags_count,
      }
    end

    def head_sha
      @head_sha ||= git("rev-parse", "HEAD").strip
    end

    def commit_count
      @commit_count ||= git("rev-list", "--count", "HEAD").strip.to_i
    end

    # Earliest root commit by author date (a repo can have several roots).
    def first_commit
      timestamps = git("rev-list", "--max-parents=0", "--format=%ct", "HEAD")
                   .lines.reject { |l| l.start_with?("commit ") }
                   .map { |l| l.strip.to_i }.reject(&:zero?)
      return nil if timestamps.empty?

      ts = timestamps.min
      { date: Time.at(ts).utc.strftime("%B %d, %Y"), timestamp: ts }
    end

    # First commit touching a path (relative to the repo root), for
    # path_scoped_age. Nil when the path has no history (or doesn't exist).
    def first_commit_for_path(path)
      return nil if path.blank?

      line = git("log", "--reverse", "--format=%ct", "--", path).lines.first
      ts = line&.strip.to_i
      ts.positive? ? { timestamp: ts, date: Time.at(ts).utc.strftime("%B %d, %Y") } : nil
    end

    def last_commit_for_path(path)
      return nil if path.blank?

      ts = git("log", "-1", "--format=%ct", "--", path).strip.to_i
      ts.positive? ? { timestamp: ts, date: Time.at(ts).utc.strftime("%B %d, %Y") } : nil
    end

    # Top-3 non-overlapping 48-hour insertion windows, each with the share of
    # total text insertions it contains (the checks.rb "repo dump" signal),
    # plus a data_fraction so a window dominated by CSV/notebook churn can be
    # distinguished from a genuine code dump.
    def code_windows
      @code_windows ||= begin
        commits = numstat_commits
        total = commits.sum { |c| c[:insertions] }
        total.zero? ? [] : select_top_windows(commits, total)
      end
    end

    # git shortlog equivalent: commits per author identity on the analyzed
    # branch, merges excluded.
    def authors
      @authors ||= git("shortlog", "-sne", "--no-merges", "HEAD").lines.filter_map do |line|
        next unless line =~ /\A\s*(\d+)\t(.*?)\s*<(.*?)>\s*\z/

        { commits: Regexp.last_match(1).to_i, name: Regexp.last_match(2), email: Regexp.last_match(3) }
      end
    end

    # CI and dependency bots must not count as collaborators — a solo project
    # plus dependabot is still a solo project.
    BOT_IDENTITY_RE = /\[bot\]|github[-_ ]?actions|actions@github\.com|actions-user|\b(dependabot|pre-commit-ci|renovate|codecov|snyk-bot|greenkeeper|allcontributors|imgbot)\b/i

    # Distinct humans after merging split identities (same person committing
    # under several name/email combinations — very common, and it inflates
    # apparent contributor counts). Bots are excluded.
    def merged_authors
      @merged_authors ||= cluster_identities(authors.reject { |a| bot_identity?(a) })
    end

    def bot_identity?(identity)
      identity[:name].to_s.match?(BOT_IDENTITY_RE) || identity[:email].to_s.match?(BOT_IDENTITY_RE)
    end

    def tags_count
      git("tag", "--list").lines.count
    end

    private

    def git(*args)
      stdout, stderr, status = Open3.capture3("git", "-C", @dir, *args)
      raise GitError, "git #{args.first} failed: #{stderr.lines.first&.strip}" unless status.success?

      stdout
    end

    # One pass over the history: commit header lines are marked with \x01 so
    # they can't be confused with file paths; numstat lines follow each header.
    # Merge commits produce no numstat lines under `git log` (no -m), so each
    # change is counted once, on the commit that introduced it.
    def numstat_commits
      out = git("log", "--numstat", "--no-renames",
                "--max-count=#{commit_cap}", "--format=\x01%H\t%ct", "HEAD")
      commits = []
      current = nil

      out.each_line do |line|
        line.chomp!
        if line.start_with?("\x01")
          sha, ts = line.delete_prefix("\x01").split("\t")
          current = { sha: sha, ts: ts.to_i, insertions: 0, data_insertions: 0 }
          commits << current
        elsif current && line =~ /\A(\d+)\t\d+\t(.+)\z/ # binary files show "-", excluded like checks.rb
          added = Regexp.last_match(1).to_i
          current[:insertions] += added
          current[:data_insertions] += added if LanguageStats.data_path?(Regexp.last_match(2))
        end
      end

      commits.sort_by { |c| c[:ts] }
    end

    def select_top_windows(commits, total)
      prefix = [0]
      data_prefix = [0]
      commits.each do |c|
        prefix << prefix.last + c[:insertions]
        data_prefix << data_prefix.last + c[:data_insertions]
      end

      # One candidate window per commit, ending at that commit's timestamp.
      candidates = []
      j = 0
      commits.each_with_index do |commit, i|
        window_start = commit[:ts] - WINDOW_SECONDS
        j += 1 while commits[j][:ts] < window_start
        insertions = prefix[i + 1] - prefix[j]
        next if insertions.zero?

        candidates << {
          from: j, to: i,
          window_start: window_start,
          window_end: commit[:ts],
          insertions: insertions,
          data_insertions: data_prefix[i + 1] - data_prefix[j],
        }
      end

      top = []
      candidates.sort_by { |w| -w[:insertions] }.each do |window|
        overlaps = top.any? do |sel|
          !(window[:window_end] < sel[:window_start] || window[:window_start] > sel[:window_end])
        end
        next if overlaps

        top << window
        break if top.length >= 3
      end

      top.map { |w| finalize_window(w, commits, total) }
    end

    def finalize_window(window, commits, total)
      members = commits[window[:from]..window[:to]].select { |c| c[:insertions].positive? }
      percentage = (window[:insertions].to_f / total * 100).round(1)
      data_fraction = (window[:data_insertions].to_f / window[:insertions]).round(3)

      {
        percentage: percentage,
        window_start: Time.at(window[:window_start]).utc.iso8601,
        window_end: Time.at(window[:window_end]).utc.iso8601,
        insertions: window[:insertions],
        first_sha: members.first&.fetch(:sha),
        last_sha: members.last&.fetch(:sha),
        signal: SIGNAL_LEVELS.find { |threshold, _| percentage >= threshold }&.last,
        data_fraction: data_fraction,
        is_data: data_fraction > DATA_WINDOW_THRESHOLD,
      }
    end

    # Union-find over author identities: merge on identical email, identical
    # normalized name, or one identity's name matching another's email
    # local-part. Heuristic, deliberately conservative.
    def cluster_identities(identities)
      parent = (0...identities.length).to_a
      find = ->(x) { parent[x] == x ? x : (parent[x] = find.call(parent[x])) }
      union = ->(a, b) { parent[find.call(a)] = find.call(b) }

      keys = identities.map do |id|
        email = id[:email].to_s.downcase.strip
        {
          name: normalize(id[:name]),
          email: email,
          local: normalize(email.split("@").first.to_s.sub(/\A\d+\+/, "")), # strip GitHub noreply id prefix
        }
      end

      keys.each_with_index do |a, i|
        keys.each_with_index do |b, jdx|
          next if jdx <= i

          same_email = a[:email].present? && a[:email] == b[:email]
          same_name = a[:name].present? && a[:name] == b[:name]
          name_is_local = a[:name].present? && (a[:name] == b[:local] || b[:name] == a[:local])
          union.call(i, jdx) if same_email || same_name || name_is_local
        end
      end

      identities.each_with_index.group_by { |_, i| find.call(i) }.map do |_, members|
        ids = members.map(&:first)
        { name: ids.max_by { |id| id[:commits] }[:name], commits: ids.sum { |id| id[:commits] } }
      end.sort_by { |a| -a[:commits] }
    end

    def normalize(str)
      str.to_s.downcase.gsub(/[^a-z0-9]/, "")
    end
  end
end
