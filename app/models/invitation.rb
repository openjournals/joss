class Invitation < ApplicationRecord
  belongs_to :editor
  belongs_to :paper

  scope :accepted, -> { where(accepted: true) }
  scope :pending, -> { where(accepted: false) }

  def accept!
    self.update_attribute(:accepted, true)
  end

  def self.accept_if_pending(paper, editor)
    invitation = pending.find_by(paper: paper, editor: editor)
    invitation.accept! if invitation
  end
end
