FactoryBot.define do
  factory :track do
    sequence(:name) { |n| "Astronomy & Astrophysics #{n}" }
    sequence(:code) { |n| n }
    sequence(:short_name) { |n| "a_and_a_#{n}" }
    aeic_ids {[create(:board_editor).id]}
  end
end
