class AddEditorIdToOnboardingInvitations < ActiveRecord::Migration[6.1]
  def change
    add_reference :onboarding_invitations, :editor
  end
end
