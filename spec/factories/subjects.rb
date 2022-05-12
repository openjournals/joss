FactoryBot.define do
  factory :subject do
    sequence(:name) {|n| "Bioengineering #{n}" }
    track_id { create(:track) }
  end
end
