class AddAcceptedAtAndInvitedToTeamAtToOnboardingInvitations < ActiveRecord::Migration[6.1]
  def change
    add_column :onboarding_invitations, :accepted_at, :datetime, default: nil
    add_column :onboarding_invitations, :invited_to_team_at, :datetime, default: nil
  end
end
