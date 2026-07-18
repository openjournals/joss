module ScopeReview
  # L1: deterministic, tri-state gate predicates over the RepoInfo blob, plus
  # the anomaly triggers that route ambiguous cases to the agentic tier.
  #
  # Every gate returns "pass" | "fail" | "unknown". Two invariants:
  #   * unknown NEVER means fail — missing data (e.g. no engagement API for a
  #     GitLab repo) escalates to a human/L3, it never desk-rejects.
  #   * model output never overrides these values — deterministic facts win.
  #
  # Routing: any hard fail → :clean_fail; any trigger or unknown → :l3;
  # otherwise → :l2. Gate 2 (research impact) is never decided here — it is
  # judgment over paper prose and always falls to L2/L3.
  class Gates
    # Editor-facing names for the gates — the single source for every UI
    # surface and prose summary. Internal keys must never reach an editor.
    LABELS = {
      license: "Open source license",
      gate1_development_history: "Public development history",
      gate2_research_impact: "Research impact",
      gate3a_open_development: "Tests & open development",
      gate3b_collaborative_effort: "Community context",
      gate4_iterative_development: "Iterative development",
    }.freeze

    def self.label(gate)
      LABELS[gate.to_sym] || gate.to_s.humanize
    end

    SIX_MONTHS_SECONDS = 182 * 24 * 60 * 60
    SINGLE_BURST_PERCENTAGE = 90.0
    NEGLIGIBLE_WINDOW_PERCENTAGE = 5.0

    INHERITED_IMPACT_RE = /\b(fork of|forked from|predecessor|successor (to|of)|earlier version|previous version|rewrite of|reimplementation of|builds? (up)?on (our|the original)|originally (developed|released)|companion (dataset|repository))\b/i
    WEB_TOOL_TEXT_RE = /\b(web[- ](tool|app|application|based|interface|platform|dashboard)|shiny app|r shiny|dashboard|graphical user interface|\bGUI\b|browser[- ]based)\b/i
    WEB_LANGUAGES = %w[JavaScript TypeScript HTML CSS Vue Svelte].freeze

    def self.evaluate(repo_info, paper_text: nil, software_version: nil, today: Time.now.utc)
      new(repo_info, paper_text, software_version, today).evaluate
    end

    def initialize(repo_info, paper_text, software_version, today)
      @info = repo_info.deep_symbolize_keys
      @paper_text = paper_text
      @software_version = software_version
      @today = today.to_time
      @triggers = []
    end

    # Soft triggers are context for L2; they don't force the expensive tier on
    # their own. Only split_identity qualifies: it is deterministic
    # bookkeeping (bot-corrected) rather than a judgment problem. Self-citation
    # overlap stays a hard L3 route — calibration showed the cheap model is
    # unstable on self-citation-dependent impact evidence (citrees).
    SOFT_TRIGGERS = %w[split_identity].freeze

    def evaluate
      gates = {
        license: license_gate,
        gate1_development_history: gate1,
        gate2_research_impact: gate2,
        gate3a_open_development: gate3a,
        gate3b_collaborative_effort: gate3b,
        gate4_iterative_development: gate4,
      }
      collect_cross_cutting_triggers

      {
        gates: gates.transform_values { |g| g[:status] },
        gate_notes: gates.transform_values { |g| g[:note] },
        triggers: @triggers,
        routing: routing(gates),
        hard_fails: gates.select { |_, g| g[:status] == "fail" }.keys,
      }
    end

    private

    def trigger(name, detail)
      @triggers << { name: name.to_s, detail: detail }
    end

    # ------------------------------------------------------------------ gates

    def license_gate
      osi = @info.dig(:license, :osi_approved)
      spdx = @info.dig(:license, :spdx_id)
      case osi
      when true then { status: "pass", note: "OSI-approved license (#{spdx})." }
      when false then { status: "fail", note: spdx ? "License #{spdx} is not OSI-approved." : "No open-source license found." }
      else { status: "unknown", note: "License present but not identifiable (#{@info.dig(:license, :file) || 'no file'}); needs human check." }
      end
    end

    def gate1
      first = @info.dig(:first_commit, :timestamp)
      return { status: "unknown", note: "First commit date could not be computed." } unless first

      age_seconds = @today.to_i - first
      age_months = (age_seconds / (30.44 * 24 * 3600)).floor
      date = @info.dig(:first_commit, :date)

      if age_seconds < SIX_MONTHS_SECONDS
        return { status: "fail",
                 note: "Repository history is #{age_months} months old (first commit #{date}) — under the 6-month minimum." }
      end

      windows = @info[:code_windows] || []
      windows.each do |w|
        next unless %w[critical strong].include?(w[:signal])

        if w[:is_data]
          trigger(:data_masked_spike,
                  "#{w[:percentage]}% of insertions in a 48h window (#{w[:window_start]}), but #{(w[:data_fraction] * 100).round}% of it is data/notebook files — classify before judging.")
        else
          trigger(:repo_dump,
                  "#{w[:percentage]}% of all insertions landed in a 48h window ending #{w[:window_end]}.")
        end
      end

      check_path_scoped_age(first)

      { status: "pass", note: "#{age_months} months of public history (first commit #{date})." }
    end

    def check_path_scoped_age(repo_first)
      %i[paper_dir primary_src_dir].each do |key|
        entry = @info.dig(:path_scoped_age, key)
        next unless entry && entry[:timestamp]

        path_age = @today.to_i - entry[:timestamp]
        gap = entry[:timestamp] - repo_first
        if path_age < SIX_MONTHS_SECONDS && key == :primary_src_dir
          trigger(:age_code_mismatch,
                  "Primary source directory '#{entry[:path]}' first touched #{entry[:date]} (<6 months ago) despite repo first commit #{@info.dig(:first_commit, :date)} — possible repurposed repo or rewrite.")
        elsif gap > 2 * SIX_MONTHS_SECONDS && path_age < 2 * SIX_MONTHS_SECONDS && key == :primary_src_dir
          trigger(:age_code_mismatch,
                  "Primary source directory '#{entry[:path]}' appeared #{entry[:date]}, over a year after the repo's first commit — check whether the submitted software is a new module in an old repo.")
        end
      end
    end

    def gate2
      overlap = self_citation_overlap
      if overlap.any?
        trigger(:self_citation_overlap,
                "Paper authors appear as authors in the bibliography (#{overlap.first(3).join(', ')}) — verify that impact evidence is not exclusively self-citation.")
      end
      { status: "unknown", note: "Not assessed yet — research impact requires reading the paper and is never decided from repository data alone." }
    end

    def gate3a
      tests = @info[:tests]
      return { status: "unknown", note: "Test signals could not be computed." } if tests.nil?

      if tests[:notebooks_only]
        trigger(:fake_test_signal, "Only notebook files found where tests are expected — verify a real automated suite exists.")
        return { status: "unknown", note: "Notebooks in test locations but no recognisable automated suite." }
      end

      if tests[:has_automated]
        ci = tests[:ci_runs_tests] ? "CI runs them" : "no CI test run detected"
        { status: "pass", note: "Automated tests detected (#{tests[:kind]}, #{tests[:test_file_count]} files; #{ci})." }
      else
        { status: "fail", note: "No automated test suite found — the 2026 baseline requires one regardless of author count. (A paper-PDF build workflow does not count.)" }
      end
    end

    def gate3b
      authors_merged = @info[:authors_merged]
      return { status: "unknown", note: "Author identities could not be computed." } unless authors_merged

      split_identity_check
      engagement = @info[:engagement] || {}
      paper_author_count = Array(@info.dig(:paper, :authors)).length
      single_author_paper = paper_author_count <= 1

      if authors_merged > 1
        return { status: "pass", note: "#{authors_merged} distinct committers after identity merging." }
      end

      unless single_author_paper
        return { status: "pass",
                 note: "Single committer but #{paper_author_count} paper authors (advisors/collaborators as co-authors count as community context)." }
      end

      if engagement[:available]
        if engagement[:unique_participants].to_i.zero?
          trigger(:solo_no_engagement,
                  "Single committer, single paper author, zero external issue/PR participants — L2/L3 must check for paper-based community evidence before this can fail.")
          { status: "unknown", note: "No repo-based community signal; paper-based evidence must be assessed." }
        else
          { status: "pass", note: "Single committer but #{engagement[:unique_participants]} external issue/PR participants." }
        end
      else
        reason = @info[:host] == "github" ? "engagement fetch failed (API auth/rate limit?)" : "no engagement adapter for host '#{@info[:host]}'"
        trigger(:engagement_unknown, "Engagement metrics unavailable (#{reason}) — unknown is not zero; needs L3/human.")
        { status: "unknown", note: "Solo project with no engagement data available — must not auto-fail." }
      end
    end

    def gate4
      windows = @info[:code_windows] || []
      return { status: "pass", note: "No dominant insertion window." } if windows.empty?

      top = windows.first
      rest = windows[1..] || []
      single_burst = top[:percentage] >= SINGLE_BURST_PERCENTAGE &&
                     rest.all? { |w| w[:percentage] < NEGLIGIBLE_WINDOW_PERCENTAGE }

      if single_burst && !top[:is_data]
        trigger(:single_burst,
                "#{top[:percentage]}% of insertions in one 48h window with no other meaningful activity — history is a burst, not iteration (lean fail; confirm at L3).")
        { status: "unknown", note: "Commit history concentrated in a single burst — escalated rather than auto-failed." }
      elsif single_burst && top[:is_data]
        trigger(:data_masked_spike, "Dominant window is #{(top[:data_fraction] * 100).round}% data files — code iteration may be healthy underneath.")
        { status: "unknown", note: "Dominant window is data churn; needs classification." }
      else
        note = top[:percentage] >= 50 ? "No single all-encompassing burst, but the top 48h window holds #{top[:percentage]}% of insertions." : "Insertions distributed across history (top window #{top[:percentage]}%)."
        { status: "pass", note: note }
      end
    end

    # ------------------------------------------------------- anomaly triggers

    def collect_cross_cutting_triggers
      inherited_impact_check
      web_tool_check
    end

    def inherited_impact_check
      version_based = @software_version.to_s.match?(/\bv?([2-9]|\d{2,})\./)
      text_based = @paper_text.present? && @paper_text.match?(INHERITED_IMPACT_RE)
      return unless version_based || text_based

      details = []
      details << "submitted version is #{@software_version}" if version_based
      details << "paper mentions a predecessor/fork/earlier version" if text_based
      trigger(:inherited_impact,
              "Impact evidence may belong to a predecessor rather than the submitted software (#{details.join('; ')}).")
    end

    def web_tool_check
      top_langs = Array(@info.dig(:languages, :top_languages))
      lang_based = top_langs.first(2).any? { |l| WEB_LANGUAGES.include?(l) }
      text_based = @paper_text.present? && @paper_text.match?(WEB_TOOL_TEXT_RE)
      siblings = Array(@info[:sibling_repos])
      return unless lang_based || text_based

      note = []
      note << "dominant language is #{top_langs.first}" if lang_based
      note << "paper describes a web/GUI tool" if text_based
      note << "related repos under same owner: #{siblings.map { |s| s[:name] }.join(', ')}" if siblings.any?
      trigger(:web_tool,
              "Possible web tool — out of scope unless it exposes a core library or shows domain-modeling rigor (#{note.join('; ')}).")
    end

    def split_identity_check
      raw = Array(@info[:authors]).length
      merged = @info[:authors_merged].to_i
      return unless merged.positive? && raw > merged

      trigger(:split_identity,
              "#{raw} committer identities merge to #{merged} distinct people — apparent contributor count is inflated.")
    end

    def self_citation_overlap
      paper_authors = Array(@info.dig(:paper, :authors)).map { |n| surname(n) }.reject(&:blank?)
      bib_authors = Array(@info.dig(:paper, :bib_authors)).map { |n| surname(n) }.reject(&:blank?)
      (paper_authors & bib_authors).uniq
    end

    def surname(name)
      name.to_s.split.last.to_s.downcase
    end

    # ----------------------------------------------------------------- routing

    def routing(gates)
      statuses = gates.values.map { |g| g[:status] }
      return :clean_fail if statuses.include?("fail")

      # Gate 2 is always "unknown" at L1 by design; it alone doesn't force the
      # expensive tier. Anything else unknown, or any HARD anomaly trigger,
      # does; soft triggers ride along as context for L2.
      other_unknowns = gates.except(:gate2_research_impact).values.count { |g| g[:status] == "unknown" }
      hard_triggers = @triggers.reject { |t| SOFT_TRIGGERS.include?(t[:name]) }
      return :l3 if other_unknowns.positive? || hard_triggers.any?

      :l2
    end
  end
end
