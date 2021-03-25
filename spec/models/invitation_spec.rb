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
end
