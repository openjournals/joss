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
class Subject < ApplicationRecord
  belongs_to :track, inverse_of: :subjects

  validates :name, uniqueness: true, presence: true
end
