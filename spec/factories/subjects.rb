FactoryBot.define do
  factory :subject do
    sequence(:name) {|n| "Bioengineering #{n}" }
    track { create(:track) }
  end
end
