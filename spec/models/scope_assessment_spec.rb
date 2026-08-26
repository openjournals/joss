require "rails_helper"

RSpec.describe ScopeAssessment do
  let(:paper) { create(:submitted_paper) }
  let(:editor) { create(:editor) }

  it "validates status and recommendation values" do
    assessment = described_class.new(paper: paper, status: "pending", recommendation: "PROCEED")
    expect(assessment).to be_valid

    assessment.status = "bogus"
    expect(assessment).not_to be_valid

    assessment.status = "pending"
    assessment.recommendation = "MAYBE"
    expect(assessment).not_to be_valid
  end

  it "is versioned: multiple assessments per paper, latest_for returns the newest" do
    old = create_assessment(created_at: 2.days.ago)
    new = create_assessment(created_at: 1.hour.ago)
    expect(described_class.latest_for(paper)).to eq(new)
    expect(paper.scope_assessments).to contain_exactly(old, new)
  end

  it "records decisions" do
    assessment = create_assessment
    assessment.approve!(editor)
    expect(assessment.reload).to have_attributes(status: "approved", decided_by: editor)
    expect(assessment.decided_at).to be_present
    expect(assessment).to be_decided
  end

  it "detects staleness by head sha" do
    assessment = create_assessment(repo_head_sha: "abc123")
    expect(assessment.stale_for?("def456")).to be(true)
    expect(assessment.stale_for?("abc123")).to be(false)
    expect(assessment.stale_for?(nil)).to be(false)
  end

  it "exposes gate results, notes and triggers from the L1 payload" do
    assessment = create_assessment(gates: {
                                     "gates" => { "license" => "pass" },
                                     "gate_notes" => { "license" => "MIT" },
                                     "triggers" => [{ "name" => "web_tool", "detail" => "JS-heavy" }],
                                   })
    expect(assessment.gate_results).to eq("license" => "pass")
    expect(assessment.gate_notes).to eq("license" => "MIT")
    expect(assessment.triggers.first["name"]).to eq("web_tool")
  end

  it "orders the queue worst-first" do
    reject = create_assessment(recommendation: "DESK_REJECT")
    proceed = create_assessment(recommendation: "PROCEED")
    verify = create_assessment(recommendation: "REQUIRES_VERIFICATION")
    expect([proceed, reject, verify].sort_by(&:queue_position)).to eq([reject, verify, proceed])
  end

  def create_assessment(attrs = {})
    described_class.create!({ paper: paper, status: "pending" }.merge(attrs))
  end
end
