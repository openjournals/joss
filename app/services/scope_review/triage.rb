module ScopeReview
  # L2: one structured pass with the cheap model over clean cases (all
  # deterministic gates passed, no anomaly triggers). Its main job is the
  # Gate 2 research-impact judgment and drafting; anything it is not confident
  # about escalates to the L3 investigator.
  #
  # Injection posture: the model's output is a DRAFT for a human plus gate
  # values that may only fill slots L1 left unknown — it can never overturn a
  # deterministic gate or trigger an outward action.
  class Triage
    MAX_TOKENS = 3000

    OUTPUT_SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: %w[gates gate_notes recommendation confidence strengths concerns summary draft_note],
      properties: {
        gates: {
          type: "object",
          additionalProperties: false,
          required: %w[gate2_research_impact gate3b_collaborative_effort],
          properties: {
            gate2_research_impact: { type: "string", enum: %w[pass fail unknown] },
            gate3b_collaborative_effort: { type: "string", enum: %w[pass fail unknown] },
          },
        },
        gate_notes: {
          type: "object",
          additionalProperties: false,
          required: %w[gate2_research_impact gate3b_collaborative_effort],
          properties: {
            gate2_research_impact: { type: "string" },
            gate3b_collaborative_effort: { type: "string" },
          },
        },
        recommendation: {
          type: "string",
          enum: %w[PROCEED BORDERLINE_PROCEED REQUIRES_VERIFICATION BORDERLINE_REJECT DESK_REJECT],
        },
        confidence: { type: "number" },
        strengths: { type: "array", items: { type: "string" } },
        concerns: { type: "array", items: { type: "string" } },
        summary: { type: "string" },
        draft_note: { type: "string" },
      },
    }.freeze

    def self.available?
      ENV["ANTHROPIC_API_KEY"].present?
    end

    def self.run(paper:, signals:, gate_results:, paper_text:)
      new(paper, signals, gate_results, paper_text).run
    end

    def initialize(paper, signals, gate_results, paper_text)
      @paper = paper
      @signals = signals
      @gate_results = gate_results
      @paper_text = paper_text
    end

    def run
      message = client.messages.create(
        model: model,
        max_tokens: MAX_TOKENS,
        system_: [{ type: "text", text: Prompts.system_prompt }],
        output_config: { format: { type: "json_schema", schema: OUTPUT_SCHEMA } },
        messages: [{ role: "user", content: prompt }]
      )

      return escalation("model refused or produced no output") if message.stop_reason == :refusal

      text = message.content.find { |b| b.type == :text }&.text
      return escalation("empty model response") if text.blank?

      parse(JSON.parse(text))
    rescue JSON::ParserError => e
      escalation("unparseable model response: #{e.message[0, 100]}")
    end

    private

    def parse(result)
      confidence = result["confidence"].to_f
      recommendation = result["recommendation"]
      # A paper only reaches L2 after passing every deterministic gate, so an
      # L2 rejection is always a judgment call — those belong to the stronger
      # tier. L2 may confidently finalize PROCEED; anything else escalates.
      escalate = confidence < confidence_threshold || recommendation != "PROCEED"

      {
        escalate: escalate,
        escalate_reason: escalate ? "confidence #{confidence} / recommendation #{recommendation}" : nil,
        recommendation: recommendation,
        confidence: confidence,
        gates: result["gates"].is_a?(Hash) ? result["gates"] : {},
        gate_notes: result["gate_notes"].is_a?(Hash) ? result["gate_notes"] : {},
        strengths: result["strengths"],
        concerns: result["concerns"],
        summary: result["summary"],
        draft_note: result["draft_note"],
        model: model,
      }
    end

    def escalation(reason)
      { escalate: true, escalate_reason: reason, model: model }
    end

    def prompt
      <<~PROMPT
        #{Prompts.context_block(paper: @paper, signals: @signals, gate_results: @gate_results, paper_text: @paper_text)}

        ## Your task

        The deterministic layer found no hard failures and no anomalies. Assess the gates it
        could not decide — above all Gate 2 (demonstrated research impact) from the paper's
        prose and bibliography, and Gate 3b where marked unknown — then give an overall
        recommendation.

        The most common Gate 2 mistake — do not make it: a citation that discusses the
        underlying METHOD or algorithm (often by unrelated authors, often predating this
        software) is NOT evidence that THIS package is used for research. Gate 2 needs
        evidence the submitted software itself is used. For every citation offered as impact
        evidence, ask: did this work use THIS package, or merely the method it implements?
        If the only works that demonstrably used the package are authored by the paper's own
        authors (check the self_citation_overlap trigger), or you cannot tell which cited
        works actually used it, recommend REQUIRES_VERIFICATION — do not PROCEED on method
        citations.

        Also report `confidence` between 0 and 1: how confident you are that a careful human
        editor would reach the same recommendation. Use a LOW confidence (<#{confidence_threshold}) whenever the
        case has genuine ambiguity (impact evidenced only by the authors' own papers,
        method-vs-package citation questions, dataset-vs-tool or frontend-vs-library
        questions, teaching-only use) — low confidence routes the case to a deeper
        investigation, which is the right outcome for ambiguity.

        `draft_note` is a plain-text draft the editor can adapt for an author-facing note; follow
        the Author-Facing Notes conventions in your instructions. Leave it an empty string when
        the recommendation is PROCEED.
      PROMPT
    end

    def client
      @client ||= Anthropic::Client.new
    end

    def model
      ScopeReview.config(:triage_model, "claude-haiku-4-5")
    end

    def confidence_threshold
      ScopeReview.config(:triage_confidence_threshold, 0.75).to_f
    end
  end
end
