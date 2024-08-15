# == Schema Information
#
# Table name: track_aeics
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  editor_id  :bigint
#  track_id   :bigint
#
# Indexes
#
#  index_track_aeics_on_editor_id  (editor_id)
#  index_track_aeics_on_track_id   (track_id)
#
class TrackAeic < ApplicationRecord
  belongs_to :editor, -> { where(kind: "board") }
  belongs_to :track

  validates_uniqueness_of :editor_id, scope: :track_id
  validate :only_aeics

  def only_aeics
    errors.add(:base, 'Editor is not an AEiC') unless editor.board?
  end
end
