class Paper < ActiveRecord::Base

  belongs_to  :submitting_author,
              :class_name => 'User',
              :validate => true,
              :foreign_key => "user_id"

  include AASM

  aasm :column => :state do
    state :submitted, :initial => true
    state :under_review
    state :review_completed
    state :superceded
    state :accepted
    state :rejected
  end

  VISIBLE_STATES = [
    "accepted",
    "superceded"
  ]

  scope :recent, lambda { where('created_at > ?', 1.week.ago) }
  scope :visible, -> { where(:state => VISIBLE_STATES) }

  before_create :set_sha

  def to_param
    sha
  end

private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
