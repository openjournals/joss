FactoryBot.define do
  factory :onboarding_invitation do
    sequence(:email) {|n| "user_#{n}@futureeditors.org" }
    token { SecureRandom.hex(5) }
  end
end
