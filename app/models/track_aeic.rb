class TrackAeic < ApplicationRecord
  belongs_to :editor, -> { where(kind: "board") }
  belongs_to :track

  validates_uniqueness_of :editor_id, scope: :track_id
  validate :only_aeics

  def only_aeics
    errors.add(:base, 'Editor is not an AEiC') unless editor.board?
  end
end
