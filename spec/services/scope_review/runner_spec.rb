require "rails_helper"

RSpec.describe ScopeReview::Runner do
  let(:paper) { create(:submitted_paper) }
  let(:adapter) { instance_double(ScopeReview::GithubAdapter) }
  let(:signals) { { head_sha: "abc123", first_commit: { timestamp: 1 } } }

  def stub_pipeline(gate_results:, paper_content: "# Statement of need")
    allow(ScopeReview::GithubAdapter).to receive(:for).and_return(adapter)
    allow(adapter).to receive(:preflight).and_return({ size_kb: 5000, default_branch: "main", license_spdx: "MIT" })
    allow(ScopeReview::Checkout).to receive(:clone).and_yield("/tmp/fake-checkout")

    repo_info = instance_double(ScopeReview::RepoInfo, to_h: signals, paper_content: paper_content)
    allow(ScopeReview::RepoInfo).to receive(:new).and_return(repo_info)
    allow(ScopeReview::Gates).to receive(:evaluate).and_return(gate_results)
  end

  describe "deterministic clean fail" do
    it "records a pending DESK_REJECT with a templated draft note, without any model call" do
      stub_pipeline(gate_results: {
                      routing: :clean_fail,
                      hard_fails: [:gate3a_open_development],
                      gates: { gate3a_open_development: "fail" },
                      gate_notes: { gate3a_open_development: "No automated test suite found." },
                      triggers: [],
                    })
      expect(ScopeReview::Triage).not_to receive(:run)

      assessment = described_class.assess(paper)

      expect(assessment).to have_attributes(
        status: "pending", recommendation: "DESK_REJECT", tier_reached: "L1", repo_head_sha: "abc123"
      )
      expect(assessment.draft_note).to include("Thanks for your submission to JOSS")
      expect(assessment.draft_note).to include("No automated test suite found.")
      expect(assessment.draft_note).to include("other-venues-for-reviewing")
      expect(assessment.draft_note).not_to match(/impressive|nicely|great/i)
      # the six-months caveat is specific to Gate 1 failures
      expect(assessment.draft_note).not_to include("Meeting the six-month development history requirement")
    end

    it "adds the six-months-alone-is-not-enough caveat to too-young rejections" do
      stub_pipeline(gate_results: {
                      routing: :clean_fail,
                      hard_fails: [:gate1_development_history],
                      gates: { gate1_development_history: "fail" },
                      gate_notes: { gate1_development_history: "Repository history is 4 months old — under the 6-month minimum." },
                      triggers: [],
                    })

      assessment = described_class.assess(paper)

      expect(assessment.draft_note).to include("Projects developed privately are not eligible")
      expect(assessment.draft_note).to include("Repository history is 4 months old")
      expect(assessment.draft_note).to include("Meeting the six-month development history requirement alone is not sufficient")
      expect(assessment.draft_note).to include("will not make a submission eligible")
    end
  end

  describe "clean pass without an API key" do
    it "degrades to needs_manual with signals attached" do
      stub_pipeline(gate_results: { routing: :l2, hard_fails: [], gates: { license: "pass" }, gate_notes: {}, triggers: [] })
      allow(ScopeReview::Triage).to receive(:available?).and_return(false)

      assessment = described_class.assess(paper)

      expect(assessment.status).to eq("needs_manual")
      expect(assessment.recommendation).to eq("NEEDS_MANUAL")
      expect(assessment.computed_signals["head_sha"]).to eq("abc123")
    end
  end

  describe "L2 path" do
    it "records the triage result when confident" do
      stub_pipeline(gate_results: { routing: :l2, hard_fails: [],
                                    gates: { license: "pass", gate2_research_impact: "unknown" },
                                    gate_notes: {}, triggers: [] })
      allow(ScopeReview::Triage).to receive(:available?).and_return(true)
      allow(ScopeReview::Triage).to receive(:run).and_return(
        escalate: false, recommendation: "PROCEED", confidence: 0.9,
        gates: { "gate2_research_impact" => "pass" }, summary: "Solid.", draft_note: "", model: "claude-haiku-4-5"
      )

      assessment = described_class.assess(paper)

      expect(assessment).to have_attributes(status: "pending", recommendation: "PROCEED", tier_reached: "L2")
      expect(assessment.model_versions["L2"]).to eq("claude-haiku-4-5")
      # model fills the unknown gate but never overrides a deterministic value
      expect(assessment.gate_results["license"]).to eq("pass")
      expect(assessment.gate_results["gate2_research_impact"]).to eq("model:pass")
    end

    it "escalates low-confidence triage to L3" do
      stub_pipeline(gate_results: { routing: :l2, hard_fails: [], gates: {}, gate_notes: {}, triggers: [] })
      allow(ScopeReview::Triage).to receive(:available?).and_return(true)
      allow(ScopeReview::Triage).to receive(:run).and_return(escalate: true, escalate_reason: "confidence 0.4", model: "claude-haiku-4-5")
      allow(ScopeReview::Investigator).to receive(:available?).and_return(true)
      allow(ScopeReview::Investigator).to receive(:run).and_return(
        capped: false, recommendation: "REQUIRES_VERIFICATION", gates: {},
        summary: "Needs a human check on X.", draft_note: "…", findings: ["a"],
        evidence_trail: [{ path: "/repos/x/y/commits", ok: true, note: "dated the module" }],
        model: "claude-sonnet-5"
      )

      assessment = described_class.assess(paper)

      expect(assessment).to have_attributes(tier_reached: "L3", recommendation: "REQUIRES_VERIFICATION", status: "pending")
      expect(assessment.evidence_trail.first["path"]).to eq("/repos/x/y/commits")
      expect(assessment.model_versions).to eq("L2" => "claude-haiku-4-5", "L3" => "claude-sonnet-5")
    end
  end

  describe "impact-only reject cap" do
    it "downgrades a model DESK_REJECT to REQUIRES_VERIFICATION when research impact is the sole failure" do
      stub_pipeline(gate_results: { routing: :l3, hard_fails: [],
                                    gates: { license: "pass", gate1_development_history: "pass", gate2_research_impact: "unknown",
                                             gate3a_open_development: "pass", gate3b_collaborative_effort: "pass", gate4_iterative_development: "pass" },
                                    gate_notes: {}, triggers: [{ name: "self_citation_overlap", detail: "x" }] })
      allow(ScopeReview::Investigator).to receive(:available?).and_return(true)
      allow(ScopeReview::Investigator).to receive(:run).and_return(
        capped: false, recommendation: "DESK_REJECT",
        gates: { "gate2_research_impact" => "fail" },
        summary: "Strong everywhere but impact is self-citation only.", draft_note: "…draft…",
        evidence_trail: [], model: "claude-sonnet-5"
      )

      assessment = described_class.assess(paper)

      expect(assessment.recommendation).to eq("REQUIRES_VERIFICATION")
      expect(assessment.summary).to include("Automated cap")
      expect(assessment.summary).to include("Strong everywhere") # model's own reasoning preserved
      expect(assessment.draft_note).to be_blank # rejection draft dropped on downgrade
    end

    it "leaves a DESK_REJECT alone when another gate also fails" do
      stub_pipeline(gate_results: { routing: :l3, hard_fails: [],
                                    gates: { license: "pass", gate2_research_impact: "unknown", gate3b_collaborative_effort: "unknown" },
                                    gate_notes: {}, triggers: [{ name: "self_citation_overlap", detail: "x" }] })
      allow(ScopeReview::Investigator).to receive(:available?).and_return(true)
      allow(ScopeReview::Investigator).to receive(:run).and_return(
        capped: false, recommendation: "DESK_REJECT",
        gates: { "gate2_research_impact" => "fail", "gate3b_collaborative_effort" => "fail" },
        summary: "Solo, no community, and impact is self-citation only.", draft_note: "…draft…",
        evidence_trail: [], model: "claude-sonnet-5"
      )

      assessment = described_class.assess(paper)

      expect(assessment.recommendation).to eq("DESK_REJECT")
    end
  end

  describe "missing paper file" do
    it "never lets a model tier judge a submission without a paper" do
      stub_pipeline(gate_results: { routing: :l3, hard_fails: [], gates: {}, gate_notes: {}, triggers: [{ name: "web_tool", detail: "x" }] },
                    paper_content: nil)
      expect(ScopeReview::Triage).not_to receive(:run)
      expect(ScopeReview::Investigator).not_to receive(:run)

      assessment = described_class.assess(paper)

      expect(assessment.status).to eq("needs_manual")
      expect(assessment.summary).to include("No paper.md")
    end
  end

  describe "L3 budget caps" do
    it "resolves a capped investigation to needs_manual, never a verdict" do
      stub_pipeline(gate_results: { routing: :l3, hard_fails: [], gates: {}, gate_notes: {}, triggers: [{ name: "web_tool", detail: "x" }] })
      allow(ScopeReview::Investigator).to receive(:available?).and_return(true)
      allow(ScopeReview::Investigator).to receive(:run).and_return(
        capped: true, capped_reason: "wall clock", summary: "partial",
        evidence_trail: [], model: "claude-sonnet-5"
      )

      assessment = described_class.assess(paper)

      expect(assessment.status).to eq("needs_manual")
      expect(assessment.recommendation).to eq("NEEDS_MANUAL")
    end
  end

  describe "oversized repository pre-flight" do
    it "skips the clone entirely and lands in the manual queue" do
      allow(ScopeReview::GithubAdapter).to receive(:for).and_return(adapter)
      allow(adapter).to receive(:preflight).and_return({ size_kb: 3_000_000 })
      expect(ScopeReview::Checkout).not_to receive(:clone)

      assessment = described_class.assess(paper)

      expect(assessment.status).to eq("needs_manual")
      expect(assessment.summary).to include("too large")
    end
  end

  describe "clone failure" do
    it "routes to needs_manual instead of erroring or deciding" do
      allow(ScopeReview::GithubAdapter).to receive(:for).and_return(nil)
      allow(ScopeReview::Checkout).to receive(:clone).and_raise(ScopeReview::Checkout::CloneError, "repository not found")

      assessment = described_class.assess(paper)

      expect(assessment.status).to eq("needs_manual")
      expect(assessment.error_message).to include("repository not found")
    end
  end

  describe "unexpected errors" do
    it "records an error assessment with no recommendation" do
      allow(ScopeReview::GithubAdapter).to receive(:for).and_raise(RuntimeError, "boom")

      assessment = described_class.assess(paper)

      expect(assessment.status).to eq("error")
      expect(assessment.recommendation).to be_nil
      expect(assessment.error_message).to include("boom")
    end
  end
end
