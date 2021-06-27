class CreateOnboardingInvitations < ActiveRecord::Migration[6.1]
  def change
    create_table :onboarding_invitations do |t|
      t.string :email
      t.string :token
      t.string :name
      t.datetime :last_sent_at

      t.timestamps
    end

    add_index :onboarding_invitations, :token
    add_index :onboarding_invitations, [:token, :email]
  end
end
