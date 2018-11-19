class Editor < ActiveRecord::Base
  validates :kind, presence: true, inclusion: { in: ["board", "topic", "emeritus"] }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :login, presence: true, unless: Proc.new { |editor| editor.kind == "emeritus"  }

  belongs_to :user
  has_many :papers

  before_save :clear_title, if: :board_removed?
  before_save :format_login, if: :login_changed?

  ACTIVE_EDITOR_STATES = [
    "board",
    "topic"
  ].freeze

  scope :board, -> { where(kind: "board") }
  scope :topic, -> { where(kind: "topic") }
  scope :emeritus, -> { where(kind: "emeritus") }
  scope :active, -> { where(:kind => ACTIVE_EDITOR_STATES) }

  def category_list
    categories.join(", ")
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
