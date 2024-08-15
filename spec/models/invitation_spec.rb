# == Schema Information
#
# Table name: invitations
#
#  id         :bigint           not null, primary key
#  state      :string           default("pending")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  editor_id  :bigint
#  paper_id   :bigint
#
# Indexes
#
#  index_invitations_on_created_at  (created_at)
#  index_invitations_on_editor_id   (editor_id)
#  index_invitations_on_paper_id    (paper_id)
#  index_invitations_on_state       (state)
#
require 'rails_helper'

describe Invitation do
  before { skip_paper_repo_url_check }

  it "at creation is not accepted" do
    invitation = Invitation.create!(paper: create(:paper), editor: create(:editor))
    expect(invitation).to_not be_accepted
  end

  it "can be accepted" do
    invitation = Invitation.create!(paper: create(:paper), editor: create(:editor))
    invitation.accept!
    expect(invitation).to be_accepted
  end

  it "can be expired" do
    invitation = Invitation.create!(paper: create(:paper), editor: create(:editor))
    invitation.expire!
    expect(invitation).to be_expired
  end

  it "can be filtered by paper's track" do
    track_A = create(:track)
    paper = create(:paper, track: track_A)

    invitation_1_in_track_A = create(:invitation, paper: paper)
    create_list(:invitation, 3)
    invitation_2_in_track_A = create(:invitation, paper: paper)

    invitations_in_track_A = Invitation.by_track(track_A.id)

    expect(invitations_in_track_A.size).to eq(2)
    expect(invitations_in_track_A.include?(invitation_1_in_track_A)).to be true
    expect(invitations_in_track_A.include?(invitation_2_in_track_A)).to be true
  end

  describe ".resolve_pending" do
    it "should accept the pending invitation of the assigned editor" do
      pending_invitation = create(:invitation, :pending)
      Invitation.resolve_pending(pending_invitation.paper, pending_invitation.editor)
      expect(pending_invitation.reload).to be_accepted
    end

    it "should do nothing if invitation already accepted" do
      invitation = create(:invitation, :accepted)
      expect { Invitation.resolve_pending(invitation.paper, invitation.editor) }.to_not change { Invitation.pending.count }
      expect { Invitation.resolve_pending(invitation.paper, invitation.editor) }.to_not change { Invitation.accepted.count }
    end

    it "should expire invitations to not assigned editors" do
      invitation_1 = create(:invitation, :pending)
      invitation_2 = create(:invitation, :pending, paper: invitation_1.paper)
      assigned_editor = create(:editor)

      Invitation.resolve_pending(invitation_1.paper, assigned_editor)
      expect(invitation_1.reload).to be_expired
      expect(invitation_2.reload).to be_expired
    end

    it "should do nothing if no invitation exists" do
      create(:invitation, :accepted)
      create(:invitation, :pending)
      expect { Invitation.resolve_pending(create(:paper), create(:editor)) }.to_not change { Invitation.pending.count }
      expect { Invitation.resolve_pending(create(:paper), create(:editor)) }.to_not change { Invitation.accepted.count }
    end
  end

  describe ".expire_all_for_paper" do
    it "should expire all pending invitations for the paper" do
      paper = create(:paper)
      invitation_1 = create(:invitation, :pending, paper: paper)
      invitation_2 = create(:invitation, :pending, paper: paper)
      invitation_3 = create(:invitation, :pending)

      Invitation.expire_all_for_paper(paper)
      expect(invitation_1.reload).to be_expired
      expect(invitation_2.reload).to be_expired
      expect(invitation_3.reload).to_not be_expired
    end

    it "should not change accepted invitations state" do
      invitation = create(:invitation, :accepted)
      expect { Invitation.expire_all_for_paper(invitation.paper) }.to_not change { Invitation.pending.count }
      expect { Invitation.expire_all_for_paper(invitation.paper) }.to_not change { Invitation.accepted.count }
    end

    it "should do nothing if paper has no pending invitations" do
      create(:invitation, :accepted)
      create(:invitation, :pending)
      expect { Invitation.expire_all_for_paper(create(:paper)) }.to_not change { Invitation.pending.count }
      expect { Invitation.expire_all_for_paper(create(:paper)) }.to_not change { Invitation.accepted.count }
    end
  end
end
