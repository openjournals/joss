require 'rails_helper'

RSpec.describe OnboardingInvitation, type: :model do
  it "should have non-empty email and token" do
    onboarding= OnboardingInvitation.new(email: "", token: "")

    expect(onboarding).to_not be_valid
    expect(onboarding.errors.messages_for(:email)).to_not be_empty
    expect(onboarding.errors.messages_for(:token)).to_not be_empty
  end

  it "should have a unique email" do
    onboarding_1 = create(:onboarding_invitation)
    onboarding_2 = OnboardingInvitation.new(email: onboarding_1.email)

    expect(onboarding_2).to_not be_valid
    expect(onboarding_2.errors.messages_for(:email)).to_not be_empty
  end

  it "should have a unique token" do
    onboarding_1 = create(:onboarding_invitation)
    onboarding_2 = OnboardingInvitation.new(token: onboarding_1.token)

    expect(onboarding_2).to_not be_valid
    expect(onboarding_2.errors.messages_for(:token)).to_not be_empty
  end

  it "should set a token before creating" do
    onboarding = OnboardingInvitation.new(email: "user@editors.org")
    onboarding.save!
    expect(onboarding.reload.token).to be_present
  end
end
