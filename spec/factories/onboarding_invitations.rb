# == Schema Information
#
# Table name: onboarding_invitations
#
#  id                 :bigint           not null, primary key
#  accepted_at        :datetime
#  email              :string
#  invited_to_team_at :datetime
#  last_sent_at       :datetime
#  name               :string
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  editor_id          :bigint
#
# Indexes
#
#  index_onboarding_invitations_on_editor_id        (editor_id)
#  index_onboarding_invitations_on_token            (token)
#  index_onboarding_invitations_on_token_and_email  (token,email)
#
FactoryBot.define do
  factory :onboarding_invitation do
    sequence(:email) {|n| "user_#{n}@futureeditors.org" }
    token { SecureRandom.hex(5) }
  end
end
