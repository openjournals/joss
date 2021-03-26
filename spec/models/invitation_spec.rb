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

  describe ".accept_if_pending" do
    it "should accept the invitation if pending" do
      pending_invitation = create(:invitation, :pending)
      Invitation.accept_if_pending(pending_invitation.paper, pending_invitation.editor)
      expect(pending_invitation.reload).to be_accepted
    end

    it "should do nothing if invitation already accepted" do
      invitation = create(:invitation, :accepted)
      expect { Invitation.accept_if_pending(invitation.paper, invitation.editor) }.to_not change { Invitation.pending.count }
      expect { Invitation.accept_if_pending(invitation.paper, invitation.editor) }.to_not change { Invitation.accepted.count }
    end

    it "should do nothing if no invitation exists" do
      create(:invitation, :accepted)
      create(:invitation, :pending)
      expect { Invitation.accept_if_pending(create(:paper), create(:editor)) }.to_not change { Invitation.pending.count }
      expect { Invitation.accept_if_pending(create(:paper), create(:editor)) }.to_not change { Invitation.accepted.count }
    end
  end
end
