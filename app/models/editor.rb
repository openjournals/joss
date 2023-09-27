class Editor < ApplicationRecord
  validates :kind, presence: true, inclusion: { in: ["board", "topic", "emeritus", "pending"] }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, unless: Proc.new { |editor| editor.kind == "emeritus" }
  validates :login, presence: true, unless: Proc.new { |editor| editor.kind == "emeritus" }
  validates :tracks, presence: true, unless: Proc.new { |editor| ["board", "emeritus"].include?(editor.kind) || !JournalFeatures.tracks? }

  belongs_to :user, optional: true
  has_many :papers
  has_many :votes
  has_many :invitations
  has_one :onboarding_invitation, dependent: :destroy
  has_and_belongs_to_many :tracks
  has_many :track_aeics, dependent: :destroy
  has_many :managed_tracks, through: :track_aeics, source: :track

  before_save :clear_title, if: :board_removed?
  before_save :format_login, if: :login_changed?
  before_save :add_default_avatar_url

  ACTIVE_EDITOR_STATES = [
    "board",
    "topic"
  ].freeze

  scope :board, -> { where(kind: "board") }
  scope :topic, -> { where(kind: "topic") }
  scope :emeritus, -> { where(kind: "emeritus") }
  scope :pending, -> { where(kind: "pending") }
  scope :active, -> { where(kind: ACTIVE_EDITOR_STATES) }
  scope :since, -> (date) { where('created_at >= ?', date) }
  scope :by_track, -> (track_id) { joins(:editors_tracks).where("editors_tracks.track_id = ?", track_id) }

  def category_list
    categories.join(", ")
  end

  def status
    if retired?
      "Retired"
    else
      "Active"
    end
  end

  def three_month_average
    paper_count = self.papers.visible.since(3.months.ago).count
    return sprintf("%.1f", paper_count / 3.0)
  end

  def self.global_three_month_average
    editor_ids = Editor.active.where("created_at <= ?", 3.months.ago).collect {|e| e.id}
    paper_count = Paper.visible.since(3.months.ago).where(editor_id: editor_ids).count

    return editor_ids.size > 0 ? sprintf("%.1f", paper_count / (3.0 * editor_ids.size)) : "0.0"
  end

  def retired?
    kind == "emeritus"
  end

  def pending?
    kind == "pending"
  end

  def accept!
    update_attribute(:kind, "topic") if self.pending?
    if invite = OnboardingInvitation.find_by(email: self.email)
      invite.destroy
    end
  end

  def category_list=(new_list = "")
    self.categories = new_list.split(/,\s+/)
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def orcid
    user.uid if user
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

  def add_default_avatar_url
    if avatar_url.blank? && login.present?
      self.avatar_url = "https://github.com/#{login}.png"
    end
  end
end
