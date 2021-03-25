class Invitation < ApplicationRecord
  belongs_to :editor
  belongs_to :paper

  def accept!
    self.update_attribute(:accepted, true)
  end
end
