class Note < ApplicationRecord
  belongs_to :paper
  belongs_to :editor

  validates :comment, presence: true

  default_scope  { order(created_at: :asc) }
end
