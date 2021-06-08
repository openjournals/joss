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

  it "should strip email before saving" do
    onboarding = OnboardingInvitation.new(email: "      user@editors.org    \n")
    onboarding.save!
    expect(onboarding.reload.email).to eq("user@editors.org")
  end

  it "should send email after creation" do
    expect { create(:onboarding_invitation) }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  describe "#send_email" do
    it "should deliver email with onboarding invitation link" do
      onboarding = create(:onboarding_invitation)
      expect { onboarding.send_email }.to change { ActionMailer::Base.deliveries.count }.by(1)
      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq([onboarding.email])
      [email.text_part.body.to_s, email.html_part.body.to_s].each do |body|
        expect(body).to match "http://test/onboardings/editor/#{onboarding.token}"
      end
    end
  end
end
