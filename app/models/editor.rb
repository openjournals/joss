class Editor < ActiveRecord::Base
  validates :kind, presence: true, inclusion: { in: ["board", "topic"] }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :login, presence: true

  before_save :clear_title, if: :board_removed?
  before_save :format_login, if: :login_changed?

  scope :board, -> { where(kind: "board") }
  scope :topic, -> { where(kind: "topic") }

  def category_list
    categories.join(", ")
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
