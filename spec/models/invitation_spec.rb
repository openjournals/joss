require 'rails_helper'

describe Invitation do
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
end
