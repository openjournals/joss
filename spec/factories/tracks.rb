# == Schema Information
#
# Table name: tracks
#
#  id         :bigint           not null, primary key
#  code       :integer
#  name       :string
#  short_name :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tracks_on_name  (name)
#
FactoryBot.define do
  factory :track do
    sequence(:name) { |n| "Astronomy & Astrophysics #{n}" }
    sequence(:code) { |n| n }
    sequence(:short_name) { |n| "a_and_a_#{n}" }
    aeic_ids {[create(:board_editor).id]}
  end
end
