# == Schema Information
#
# Table name: subjects
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  track_id   :bigint
#
# Indexes
#
#  index_subjects_on_name_and_track_id  (name,track_id)
#  index_subjects_on_track_id           (track_id)
#
FactoryBot.define do
  factory :subject do
    sequence(:name) {|n| "Bioengineering #{n}" }
    track { create(:track) }
  end
end
