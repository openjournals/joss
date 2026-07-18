module ScopeReview
  # Orchestrates one assessment: pre-flight → clone → L0 signals → L1 gates →
  # (L2 triage | L3 investigation) → ScopeAssessment row.
  #
  # Fail-safe rules, in order:
  #   * Any error, timeout, or budget hit resolves to needs_manual — never to
  #     a verdict.
  #   * Deterministic L1 gate values always override model gate output.
  #   * No outward action is taken anywhere in this path.
  class Runner
    ONE_GB_KB = 1_048_576

    def self.assess(paper)
      new(paper).assess
    end

    def initialize(paper)
      @paper = paper
    end

    def assess
      adapter = GithubAdapter.for(@paper.repository_url)
      host_data = adapter ? adapter.preflight : {}

      if oversized?(host_data)
        return record(
          status: "needs_manual", tier_reached: "L0", recommendation: "NEEDS_MANUAL",
          computed_signals: { host_meta: host_data, repo_url: @paper.repository_url },
          summary: "Repository is #{(host_data[:size_kb] / 1024.0 / 1024.0).round(2)} GB " \
                   "(threshold #{(max_size_kb / 1024.0 / 1024.0).round(1)} GB) — too large for automated analysis; assess manually."
        )
      end

      Checkout.clone(@paper.repository_url, branch: @paper.git_branch.presence) do |dir|
        assess_checkout(dir, host_data, adapter)
      end
    rescue Checkout::CloneError => e
      record(status: "needs_manual", tier_reached: "L0", recommendation: "NEEDS_MANUAL",
             error_message: e.message,
             summary: "The repository could not be cloned (#{e.message}). Check the URL/branch or assess manually.")
    rescue StandardError => e
      trace = e.backtrace.grep(%r{app/services/scope_review}).first(3).join(" | ")
      Rails.logger.error("ScopeReview::Runner failed for paper #{@paper.id}: #{e.class}: #{e.message} @ #{trace}")
      record(status: "error", recommendation: nil,
             error_message: "#{e.class}: #{e.message.to_s[0, 300]} @ #{trace[0, 400]}")
    end

    private

    def assess_checkout(dir, host_data, adapter)
      repo_info = RepoInfo.new(dir: dir, repo_url: @paper.repository_url,
                               host_data: host_data, adapter: adapter)
      signals = repo_info.to_h
      paper_text = repo_info.paper_content

      gate_results = Gates.evaluate(signals,
                                    paper_text: paper_text,
                                    software_version: @paper.software_version)

      case gate_results[:routing]
      when :clean_fail
        # Deterministic hard fails (repo age, missing tests, license) hold
        # with or without a paper file.
        record_clean_fail(signals, gate_results)
      when :l2, :l3
        # The rubric's first rule: never assess scope without reading the
        # paper. No paper.md → no model verdict; the editor needs to ask the
        # author to add or rename the paper file.
        return record_missing_paper(signals, gate_results) unless paper_text.present?

        if gate_results[:routing] == :l2
          run_triage(signals, gate_results, paper_text)
        else
          run_investigation(signals, gate_results, paper_text)
        end
      end
    end

    def record_missing_paper(signals, gate_results)
      branch = @paper.git_branch.presence || "the default branch"
      record(
        status: "needs_manual", tier_reached: "L1", recommendation: "NEEDS_MANUAL",
        computed_signals: signals, gates: gate_results,
        summary: "No paper.md found on #{branch} — scope cannot be assessed without the paper. " \
                 "Ask the author to add the paper file in the required format."
      )
    end

    # A deterministic hard fail needs no model to decide — only to phrase.
    # The draft is templated from computed facts; an EiC still approves it.
    def record_clean_fail(signals, gate_results)
      failed = gate_results[:hard_fails].map { |g| Gates.label(g).downcase }
      record(
        status: "pending", tier_reached: "L1", recommendation: "DESK_REJECT",
        computed_signals: signals, gates: gate_results,
        summary: "Deterministic gate failure: #{failed.join(', ')}.",
        draft_note: DraftNote.for_clean_fail(@paper, gate_results)
      )
    end

    def run_triage(signals, gate_results, paper_text)
      return record_no_model(signals, gate_results, "L1") unless Triage.available?

      result = Triage.run(paper: @paper, signals: signals, gate_results: gate_results, paper_text: paper_text)
      if result[:escalate]
        run_investigation(signals, gate_results, paper_text, triage_result: result)
      else
        merged = merge_model_gates(gate_results, result)
        recommendation, summary, draft_note = cap_impact_only_reject(result[:recommendation], merged, result[:summary], result[:draft_note])
        record(
          status: "pending", tier_reached: "L2",
          recommendation: recommendation,
          computed_signals: signals, gates: merged,
          summary: summary, draft_note: draft_note,
          model_versions: { "L2" => result[:model] }
        )
      end
    end

    def run_investigation(signals, gate_results, paper_text, triage_result: nil)
      return record_no_model(signals, gate_results, "L1") unless Investigator.available?

      result = Investigator.run(paper: @paper, signals: signals, gate_results: gate_results,
                                paper_text: paper_text, triage_result: triage_result)
      merged = merge_model_gates(gate_results, result)
      recommendation = result[:capped] ? "NEEDS_MANUAL" : result[:recommendation]
      summary = result[:summary]
      draft_note = result[:draft_note]
      unless result[:capped]
        recommendation, summary, draft_note = cap_impact_only_reject(recommendation, merged, summary, draft_note)
      end

      record(
        status: result[:capped] ? "needs_manual" : "pending",
        tier_reached: "L3",
        recommendation: recommendation,
        computed_signals: signals, gates: merged,
        summary: summary, draft_note: draft_note,
        evidence_trail: result[:evidence_trail],
        model_versions: { "L2" => triage_result&.dig(:model), "L3" => result[:model] }.compact
      )
    end

    # A desk rejection whose ONLY failing gate is research impact is never
    # actioned autonomously: when a submission is strong on every other axis
    # (history, tests, community, license, iteration) and falls short only on
    # demonstrated impact, that is a judgment call an editor must make — high
    # standards elsewhere can outweigh thin (e.g. self-citation-only) impact
    # evidence. Downgrade the model's reject to REQUIRES_VERIFICATION.
    def cap_impact_only_reject(recommendation, merged_gates, summary, draft_note)
      return [recommendation, summary, draft_note] unless %w[DESK_REJECT BORDERLINE_REJECT].include?(recommendation)

      failing = (merged_gates[:gates] || {}).select { |_, v| v.to_s.include?("fail") }.keys.map(&:to_sym)
      return [recommendation, summary, draft_note] unless failing == [:gate2_research_impact]

      note = "\n\n[Automated cap: the only gate this fails is demonstrated research impact; " \
             "because the submission is otherwise strong, this is surfaced for editorial " \
             "verification rather than an automated desk rejection.]"
      # Drop the model's rejection draft — the editor is being asked to decide,
      # so there is no author-facing note to pre-write yet.
      ["REQUIRES_VERIFICATION", "#{summary}#{note}", nil]
    end

    # Without an API key the deterministic layers still run: clean fails are
    # recorded above, everything else lands in the manual queue with signals
    # attached — the pipeline degrades to "very good triage notes".
    def record_no_model(signals, gate_results, tier)
      by_status = gate_results[:gates].group_by { |_, v| v }
      breakdown = %w[fail unknown pass].filter_map do |status|
        gates = by_status[status] or next
        "#{status == 'pass' ? 'passed' : status}: #{gates.map { |g, _| Gates.label(g).downcase }.join(', ')}"
      end

      record(
        status: "needs_manual", tier_reached: tier, recommendation: "NEEDS_MANUAL",
        computed_signals: signals, gates: gate_results,
        summary: "The model tiers are unavailable (no API key configured), so this needs manual assessment. " \
                 "Deterministic checks — #{breakdown.join('; ')}."
      )
    end

    # Deterministic gates always win over model opinions; model may only fill
    # gates L1 left unknown. Model output is untrusted in shape as well as
    # content — anything that isn't a Hash is ignored.
    def merge_model_gates(gate_results, model_result)
      merged = gate_results.deep_dup
      model_gates = model_result[:gates]
      model_gates = {} unless model_gates.is_a?(Hash)
      merged[:gates] = merged[:gates].to_h do |gate, value|
        model_value = model_gates[gate.to_s] || model_gates[gate]
        [gate, value == "unknown" && model_value.present? ? "model:#{model_value}" : value]
      end
      merged
    end

    def record(attrs)
      defaults = {
        computed_signals: {}, gates: {}, evidence_trail: [], model_versions: {},
      }
      @paper.scope_assessments.create!(defaults.merge(attrs).merge(
        repo_head_sha: attrs.dig(:computed_signals, :head_sha)
      ))
    end

    def oversized?(host_data)
      host_data[:size_kb].to_i > max_size_kb
    end

    def max_size_kb
      ScopeReview.config(:max_repo_size_kb, ONE_GB_KB)
    end
  end
end
