class Invitation < ApplicationRecord
  belongs_to :editor
  belongs_to :paper

  validates :state, presence: true, inclusion: { in: ["pending", "accepted", "expired"] }

  scope :accepted, -> { where(state: "accepted") }
  scope :pending, -> { where(state: "pending") }
  scope :expired, -> { where(state: "expired") }
  scope :by_track, -> (track_id) { joins(:paper).where("papers.track_id = ?", track_id) }

  def expired?
    state == "expired"
  end

  def pending?
    state == "pending"
  end

  def accepted?
    state == "accepted"
  end

  def accept!
    self.update_attribute(:state, "accepted")
  end

  def expire!
    self.update_attribute(:state, "expired")
  end

  def self.resolve_pending(paper, editor)
    pending_invitations = pending.where(paper: paper)

    pending_invitations.each do |invitation|
      if invitation.editor_id == editor.id
        invitation.accept!
      else
        invitation.expire!
      end
    end
  end

  def self.expire_all_for_paper(paper)
    pending.where(paper: paper).update_all(state: "expired")
  end
end
