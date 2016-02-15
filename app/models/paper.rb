class Paper < ActiveRecord::Base

  belongs_to  :submitting_author,
              :class_name => 'User',
              :validate => true,
              :foreign_key => "user_id"

  include AASM

  aasm :column => :state do
    state :submitted, :initial => true
    state :under_review
    state :review_completed
    state :superceded
    state :accepted
    state :rejected
  end

  VISIBLE_STATES = [
    "accepted",
    "superceded"
  ]

  scope :recent, lambda { where('created_at > ?', 1.week.ago) }
  scope :submitted, lambda { where('state = ?', 'submitted') }
  scope :visible, -> { where(:state => VISIBLE_STATES) }

  before_create :set_sha

  validates_presence_of :title
  validates_presence_of :repository_url, :message => "^Repository address can't be blank"
  validates_presence_of :archive_doi, :message => "^DOI can't be blank"
  validates_presence_of :body, :message => "^Description can't be blank"

  def to_param
    sha
  end

  def pretty_repository_name
    if repository_url.include?('github.com')
      name, owner = repository_url.scan(/(?<=github.com\/).*/i).first.split('/')
      return "#{name} / #{owner}"
    else
      return repository_url
    end
  end

  def pretty_doi
    matches = archive_doi.scan(/\b(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?!["&\'<>])\S)+)\b/).flatten

    if matches.any?
      return matches.first
    else
      return archive_doi
    end
  end

private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
