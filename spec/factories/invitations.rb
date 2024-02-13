FactoryBot.define do
  factory :invitation do
    paper { create(:paper) }
    editor { create(:editor) }

    trait :pending do
      state { 'pending' }
    end

    trait :accepted do
      state { 'accepted' }
    end

    trait :expired do
      state { 'expired' }
    end
  end
end
