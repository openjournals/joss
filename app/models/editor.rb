class Editor < ApplicationRecord
  validates :kind, presence: true, inclusion: { in: ["board", "topic", "emeritus"] }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :login, presence: true, unless: Proc.new { |editor| editor.kind == "emeritus"  }

  belongs_to :user, optional: true
  has_many :papers
  has_many :votes
  has_many :invitations

  before_save :clear_title, if: :board_removed?
  before_save :format_login, if: :login_changed?

  ACTIVE_EDITOR_STATES = [
    "board",
    "topic"
  ].freeze

  scope :board, -> { where(kind: "board") }
  scope :topic, -> { where(kind: "topic") }
  scope :emeritus, -> { where(kind: "emeritus") }
  scope :active, -> { where(kind: ACTIVE_EDITOR_STATES) }
  scope :since, -> (date) { where('created_at >= ?', date) }

  def category_list
    categories.join(", ")
  end

  def three_month_average
    paper_count = self.papers.visible.since(3.months.ago).count
    return sprintf("%.1f", paper_count / 3.0)
  end

  def self.global_three_month_average
    editor_ids = Editor.active.where("created_at <= ?", 3.months.ago).collect {|e| e.id}
    paper_count = Paper.visible.since(3.months.ago).where(editor_id: editor_ids).count

    return sprintf("%.1f", paper_count / (3.0 * editor_ids.size))
  end

  def retired?
    kind == "emeritus"
  end

  def category_list=(new_list = "")
    self.categories = new_list.split(/,\s+/)
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def orcid
    user.uid
  end

  def clear_title
    self.title = nil
  end

  def board?
    kind == "board"
  end

  def board_removed?
    kind_changed? && kind_was == "board"
  end

  def format_login
    login.gsub!(/^@/, "")
  end
end
