module ScopeAssessmentsHelper
  # Display names come from ScopeReview::Gates::LABELS — one map for every
  # surface (table, tooltips, sidebar help, prose summaries).
  GATE_LABELS = ScopeReview::Gates::LABELS.transform_keys(&:to_s).freeze

  # Shown as a tooltip on each row so editors don't need the internal rubric
  # to interpret the checks.
  GATE_DESCRIPTIONS = {
    "license" => "The repository must carry an OSI-approved open-source license.",
    "gate1_development_history" => "At least six months of public development history prior to submission — a recent dump of code into a repository doesn't count.",
    "gate2_research_impact" => "Evidence the software is already used for research (publications, external adoption, operational deployment) — never decided automatically; always needs prose judgment.",
    "gate3a_open_development" => "An automated test suite is a hard requirement; open-source workflow signals (releases, docs, CONTRIBUTING) support it.",
    "gate3b_collaborative_effort" => "Development shaped by a broader community — multiple contributors, external feedback, or community evidence in the paper for solo projects.",
    "gate4_iterative_development" => "Ongoing refinement over time rather than a single burst of commits.",
  }.freeze

  GATE_MARKS = { "pass" => "✓", "fail" => "✗", "unknown" => "?" }.freeze

  def scope_gate_label(gate)
    ScopeReview::Gates.label(gate)
  end

  def scope_gate_description(gate)
    GATE_DESCRIPTIONS[gate.to_s]
  end

  def scope_recommendation_badge(assessment)
    label = assessment.recommendation || assessment.status.upcase
    content_tag(:span, label.tr("_", " "),
                class: "scope-badge #{label.downcase.tr('_', '-')}")
  end

  # "pass" / "fail" / "unknown" / "model:pass" → a small colored mark + word.
  def scope_gate_badge(status)
    from_model = status.to_s.start_with?("model:")
    value = status.to_s.delete_prefix("model:")
    mark = GATE_MARKS[value] || "•"
    text = from_model ? "#{value} (model)" : value
    content_tag(:span, "#{mark} #{text}", class: "scope-gate-status #{value}")
  end

  def scope_gate_summary(assessment)
    marks = assessment.gate_results.map do |_, status|
      value = status.to_s.sub(/\Amodel:/, "")
      content_tag(:span, GATE_MARKS[value] || "•", class: "scope-gate-status #{value}")
    end
    safe_join(marks, " ")
  end
end
