require "rails_helper"

RSpec.describe PapersController, type: :controller do
  render_views false

  describe "POST #desk_reject" do
    let(:aeic_user) { create(:user, editor: create(:board_editor)) }
    let(:paper) { create(:paper, state: "submitted", sha: SecureRandom.hex(16)) }

    before do
      allow(controller).to receive_message_chain(:current_user).and_return(aeic_user)
      paper # create up front — Paper's own creation emails must not count in the examples
      ActionMailer::Base.deliveries.clear
    end

    it "rejects the paper and emails the author the editor's message" do
      expect {
        post :desk_reject, params: { id: paper.sha, message: "Thanks for your submission to JOSS. Not yet.", send_email: "1" }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(paper.reload.state).to eq("rejected")
      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq([paper.submitting_author.email])
      expect(email.text_part.body.to_s).to include("Not yet.")
    end

    it "rejects without emailing when the box is unticked" do
      expect {
        post :desk_reject, params: { id: paper.sha, message: "whatever" }
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(paper.reload.state).to eq("rejected")
    end

    it "refuses to email an empty message" do
      post :desk_reject, params: { id: paper.sha, message: "", send_email: "1" }
      expect(paper.reload.state).to eq("submitted")
      expect(flash[:error]).to be_present
    end

    it "records the decision on the pending assessment, preserving the edited note" do
      assessment = ScopeAssessment.create!(paper: paper, status: "pending",
                                           recommendation: "DESK_REJECT", draft_note: "original draft")

      post :desk_reject, params: { id: paper.sha, message: "edited by the editor", send_email: "1" }

      expect(assessment.reload).to have_attributes(status: "approved", draft_note: "edited by the editor")
      expect(assessment.decided_by).to eq(aeic_user.editor)
    end

    it "is forbidden for non-AEiC users" do
      editor = create(:user, editor: create(:editor))
      allow(controller).to receive_message_chain(:current_user).and_return(editor)

      post :desk_reject, params: { id: paper.sha, message: "x", send_email: "1" }
      expect(paper.reload.state).to eq("submitted")
    end
  end
end
