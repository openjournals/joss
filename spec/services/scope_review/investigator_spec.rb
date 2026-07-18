require "rails_helper"

RSpec.describe ScopeReview::Investigator do
  let(:paper) { build(:paper, repository_url: "https://github.com/example/tool") }
  subject(:investigator) { described_class.new(paper, {}, { gates: {}, gate_notes: {}, triggers: [] }, "paper text", nil) }

  describe "malformed tool-call repair" do
    it "re-splits parameters the API parser swallowed into one string" do
      input = {
        "recommendation" => "DESK_REJECT",
        "summary" => "Fails gates 2 and 3b.</summary>\n<parameter name=\"draft_note\">Thanks for your submission.\n\nNot yet.",
      }
      repaired = investigator.send(:repair_submission, input)

      expect(repaired["summary"]).to eq("Fails gates 2 and 3b.")
      expect(repaired["draft_note"]).to eq("Thanks for your submission.\n\nNot yet.")
      expect(investigator.send(:valid_submission?, repaired)).to be(true)
    end

    it "leaves well-formed submissions untouched" do
      input = { "recommendation" => "PROCEED", "summary" => "All good.", "draft_note" => "", "findings" => ["a"] }
      expect(investigator.send(:repair_submission, input)).to eq(input)
      expect(investigator.send(:valid_submission?, input)).to be(true)
    end

    it "rejects submissions with a bogus recommendation or empty summary" do
      expect(investigator.send(:valid_submission?, { "recommendation" => "MAYBE", "summary" => "x" })).to be(false)
      expect(investigator.send(:valid_submission?, { "recommendation" => "PROCEED", "summary" => "" })).to be(false)
    end
  end
end
