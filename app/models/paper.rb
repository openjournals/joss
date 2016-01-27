class Paper < ActiveRecord::Base
  include AASM
  aasm :column => :state do
    state :submitted, :initial => true
    state :under_review
    state :review_completed
    state :superceded
    state :accepted
    state :rejected
  end
end
