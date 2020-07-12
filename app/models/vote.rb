class Vote < ActiveRecord::Base
  belongs_to :paper
  belongs_to :editor

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

  validates :kind, inclusion: { in: VOTE_KINDS }, allow_nil: false
end
