FactoryBot.define do
  factory :invitation do
    paper { create(:paper) }
    editor { create(:editor) }

    trait :pending do
      accepted { false }
    end

    trait :accepted do
      accepted { true }
    end
  end
end
