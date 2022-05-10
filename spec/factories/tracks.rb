FactoryBot.define do
  factory :track do
    name { "Astronomy & Astrophysics" }
    sequence(:code) { |n| n }
    short_name { "a_and_a" }
  end
end
