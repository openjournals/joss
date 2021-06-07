class CreateOnboardingInvitations < ActiveRecord::Migration[6.1]
  def change
    create_table :onboarding_invitations do |t|
      t.string :email
      t.string :token

      t.timestamps
    end
  end
end
