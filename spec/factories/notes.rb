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
FactoryBot.define do
  factory :note do
    editor { create(:editor) }
    paper { create(:review_pending_paper) }
    sequence(:comment) {|n| "Testing editor notes #{n}" }
  end
end
