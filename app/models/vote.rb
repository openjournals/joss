# == Schema Information
#
# Table name: votes
#
#  id         :bigint           not null, primary key
#  comment    :text
#  kind       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  editor_id  :integer
#  paper_id   :integer
#
# Indexes
#
#  index_votes_on_editor_id               (editor_id)
#  index_votes_on_editor_id_and_paper_id  (editor_id,paper_id) UNIQUE
#  index_votes_on_kind                    (kind)
#  index_votes_on_paper_id                (paper_id)
#
class Vote < ApplicationRecord
  belongs_to :paper
  belongs_to :editor

  validates :comment, presence: true

  VOTE_KINDS = [
    "in-scope",
    "out-of-scope",
    "comment"
  ].freeze

  default_scope  { order(created_at: :desc) }
  scope :in_scope, lambda { where('kind = ?', 'in-scope') }
  scope :out_of_scope, lambda { where('kind = ?', 'out-of-scope') }
  scope :comment_only, lambda { where('kind = ?', 'comment') }

  def in_scope?
    kind == "in-scope"
  end

  def out_of_scope?
    kind == "out-of-scope"
  end

  def comment?
    kind == "comment"
  end

  def self.has_vote_for?(paper, editor)
    find_by_paper_id_and_editor_id(paper, editor)
  end

  validates :kind, inclusion: { in: VOTE_KINDS }, allow_nil: false
end
