# == Schema Information
#
# Table name: notes
#
#  id         :bigint           not null, primary key
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  editor_id  :integer
#  paper_id   :integer
#
# Indexes
#
#  index_notes_on_editor_id  (editor_id)
#  index_notes_on_paper_id   (paper_id)
#
class Note < ApplicationRecord
  belongs_to :paper
  belongs_to :editor

  validates :comment, presence: true

  default_scope  { order(created_at: :asc) }
end
