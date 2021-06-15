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

  describe "#accepted!" do
    it "should update accepted_at info" do
      onboarding = create(:onboarding_invitation)
      expect(onboarding.accepted_at).to be_nil

      onboarding.accepted!
      accepted_at_1 = onboarding.reload.accepted_at

      onboarding.accepted!
      accepted_at_2 = onboarding.reload.accepted_at

      expect(accepted_at_1).to_not be_nil
      expect(accepted_at_2).to_not be_nil
      expect(accepted_at_1 < accepted_at_2).to be true
    end
  end

  describe "#accepted?" do
    it "should be true if accepted_at is present" do
      onboarding = create(:onboarding_invitation, accepted_at: Time.now)
      expect(onboarding.accepted?).to be true
    end

    it "should be false if accepted_at is nil" do
      onboarding = create(:onboarding_invitation, accepted_at: nil)
      expect(onboarding.accepted?).to be false
    end
  end

  describe "#invited_to_team!" do
    it "should update invited_to_team_at info" do
      onboarding = create(:onboarding_invitation)
      expect(onboarding.invited_to_team_at).to be_nil

      onboarding.invited_to_team!
      invited_to_team_at_1 = onboarding.reload.invited_to_team_at

      onboarding.invited_to_team!
      invited_to_team_at_2 = onboarding.reload.invited_to_team_at

      expect(invited_to_team_at_1).to_not be_nil
      expect(invited_to_team_at_2).to_not be_nil
      expect(invited_to_team_at_1 < invited_to_team_at_2).to be true
    end
  end

  describe "#invited_to_team?" do
    it "should be true if invited_to_team_at is present" do
      onboarding = create(:onboarding_invitation, invited_to_team_at: Time.now)
      expect(onboarding.invited_to_team?).to be true
    end

    it "should be false if invited_to_team_at is nil" do
      onboarding = create(:onboarding_invitation, invited_to_team_at: nil)
      expect(onboarding.invited_to_team?).to be false
    end
  end

  describe "pending_acceptance scope" do
    it "should return only accepted onboarding invitations" do
      accepted_onboarding = create(:onboarding_invitation, accepted_at: Time.now)
      not_accepted_onboarding = create(:onboarding_invitation, accepted_at: nil)

      scope_results = OnboardingInvitation.pending_acceptance.to_a
      expect(scope_results).to eq([not_accepted_onboarding])
    end

    it "should be false if invited_to_team_at is nil" do
      onboarding = create(:onboarding_invitation, invited_to_team_at: nil)
      expect(onboarding.invited_to_team?).to be false
    end
  end
end
