class Paper < ActiveRecord::Base
  include SettingsHelper
  serialize :activities, Hash

  belongs_to  :submitting_author,
              :class_name => 'User',
              :validate => true,
              :foreign_key => "user_id"

  belongs_to  :editor

  include AASM

  aasm :column => :state do
    state :submitted, :initial => true
    state :review_pending
    state :under_review
    state :review_completed
    state :superceded
    state :accepted
    state :rejected
    state :withdrawn

    event :reject do
      transitions :to => :rejected
    end

    event :start_meta_review do
      transitions :from => :submitted, :to => :review_pending, :if => :create_meta_review_issue
    end

    event :start_review do
      transitions :from => :review_pending, :to => :under_review, :if => :create_review_issue
    end

    event :accept do
      transitions :to => :accepted
    end

    event :withdraw do
      transitions :to => :withdrawn
    end
  end

  VISIBLE_STATES = [
    "accepted",
    "superceded"
  ].freeze

  IN_PROGRESS_STATES = [
    "submitted",
    "under_review",
    "review_pending"
  ].freeze

  INVISIBLE_STATES = [
    "submitted",
    "rejected",
    "withdrawn"
  ].freeze

  default_scope  { order(:created_at => :desc) }
  scope :recent, lambda { where('created_at > ?', 1.week.ago) }
  scope :submitted, lambda { where('state = ?', 'submitted') }

  scope :since, -> (date) { where('accepted_at >= ?', date) }
  scope :in_progress, -> { where(:state => IN_PROGRESS_STATES) }
  scope :visible, -> { where(:state => VISIBLE_STATES) }
  scope :invisible, -> { where(:state => INVISIBLE_STATES) }
  scope :everything, lambda { where('state NOT IN (?)', ['rejected', 'withdrawn']) }

  before_create :set_sha, :set_last_activity
  after_create :notify_editors, :notify_author

  validates_presence_of :title
  validates_presence_of :repository_url, :message => "^Repository address can't be blank"
  validates_presence_of :software_version, :message => "^Version can't be blank"
  validates_presence_of :body, :message => "^Description can't be blank"
  validates :kind, inclusion: { in: Rails.application.settings["paper_types"] }, allow_nil: true

  def notify_editors
    Notifications.submission_email(self).deliver_now
  end

  def notify_author
    Notifications.author_submission_email(self).deliver_now
  end

  def self.featured
    # TODO: Make this a thing
    Paper.first
  end

  def self.popular
    recent
  end

  def to_param
    sha
  end

  def invisible?
    INVISIBLE_STATES.include?(state)
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
    return "DOI pending" unless archive_doi

    matches = archive_doi.scan(/\b(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?!["&\'<>])\S)+)\b/).flatten

    if matches.any?
      return matches.first
    else
      return archive_doi
    end
  end

  # Make sure that DOIs have a full http URL
  # e.g. turn 10.6084/m9.figshare.828487 into https://doi.org/10.6084/m9.figshare.828487
  def doi_with_url
    return "DOI pending" unless archive_doi

    bare_doi = archive_doi[/\b(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?!["&\'<>])\S)+)\b/]

    if archive_doi.include?("https://doi.org/")
      return archive_doi
    elsif bare_doi
      return "https://doi.org/#{bare_doi}"
    else
      return archive_doi
    end
  end

  def clean_archive_doi
    doi_with_url.gsub(/\"/, "")
  end

  # A 5-figure integer used to produce the JOSS DOI
  def joss_id
    id = "%05d" % review_issue_id
    "#{setting(:abbreviation).downcase}.#{id}"
  end

  # Where to find the PDF for this paper
  def pdf_url
    doi_to_file = doi.gsub('/', '.')

    "#{Rails.application.settings["papers_html_url"]}/#{joss_id}/#{doi_to_file}.pdf"
  end

  # 'reviewers' should be a string (and may be comma-separated)
  def review_body(editor, reviewers)
    reviewers = reviewers.split(',').each {|r| r.prepend('@')}

    ActionView::Base.new(Rails.configuration.paths['app/views']).render(
      :template => 'shared/review_body', :format => :txt,
      :locals => { :paper => self, :editor => "@#{editor}", :reviewers => reviewers }
    )
  end

  # Create a review issue (we know the reviewer and editor at this point)
  # Return false if the review_issue_id is already set
  # Return false if the editor login doesn't match one of the known editors
  def create_review_issue(editor_handle, reviewers)
    return false if review_issue_id
    return false unless editor = Editor.find_by_login(editor_handle)

    issue = GITHUB.create_issue(Rails.application.settings["reviews"],
                                "[REVIEW]: #{self.title}",
                                review_body(editor_handle, reviewers),
                                { :assignees => [editor_handle],
                                  :labels => "review" })

    set_review_issue(issue.number)
    set_editor(editor)
    set_reviewers(reviewers)
  end

  # Update the paper with the reviewer GitHub handles
  def set_reviewers(reviewers)
    reviewers = reviewers.split(',').each(&:strip!).each {|r| r.prepend('@') unless r.start_with?('@') }
    self.update_attribute(:reviewers, reviewers)
  end

  # Updated the paper with the editor_id
  def set_editor(editor)
    self.update_attribute(:editor_id, editor.id)
  end

  # Update the Paper review_issue_id field
  def set_review_issue(issue_number)
    self.update_attribute(:review_issue_id, issue_number)
  end

  def meta_review_body(editor)
    if editor.strip.empty?
      locals = { :paper => self, :editor => "Pending" }
    else
      locals = { :paper => self, :editor => "#{editor}" }
    end
    ActionView::Base.new(Rails.configuration.paths['app/views']).render(
      :template => 'shared/meta_view_body', :format => :txt,
      :locals => locals
    )
  end

  # Create a review meta-issue for assigning reviewers
  def create_meta_review_issue(editor_handle)
    if editor_handle
      striped_handle = editor_handle.gsub('@', '')
    else
      striped_handle = editor_handle
    end

    return false if meta_review_issue_id

    # If an editor handle has been passed then look up the editor
    if !editor_handle.blank?
      if editor = Editor.find_by_login(striped_handle)
        set_editor(editor)
      else
        # If we've been passed an editor handle but can't find the editor we
        # should fail here.
        return false
      end
    end

    issue = GITHUB.create_issue(Rails.application.settings["reviews"],
                                "[PRE REVIEW]: #{self.title}",
                                meta_review_body(editor_handle),
                                { :assignee => striped_handle,
                                  :labels => "pre-review" })

    set_meta_review_issue(issue.number)
  end

  # Update the Paper meta_review_issue_id field
  def set_meta_review_issue(issue_number)
    self.update_attribute(:meta_review_issue_id, issue_number)
  end

  def meta_review_url
    "https://github.com/#{Rails.application.settings["reviews"]}/issues/#{self.meta_review_issue_id}"
  end

  def review_url
    "https://github.com/#{Rails.application.settings["reviews"]}/issues/#{self.review_issue_id}"
  end

  def update_review_issue(comment)
    GITHUB.add_comment(Rails.application.settings["reviews"], self.review_issue_id, comment)
  end

  def pretty_state
    state.humanize.downcase
  end

  # Returns DOI with URL e.g. "https://doi.org/10.21105/joss.00001"
  def cross_ref_doi_url
    "https://doi.org/#{doi}"
  end

  def status_badge
    prefix = setting(:abbreviation)

    case self.state.to_s
    when "submitted"
      "<svg xmlns='http://www.w3.org/2000/svg' width='108' height='20'><linearGradient id='b' x2='0' y2='100%'><stop offset='0' stop-color='#bbb' stop-opacity='.1'/><stop offset='1' stop-opacity='.1'/></linearGradient><mask id='a'><rect width='108' height='20' rx='3' fill='#fff'/></mask><g mask='url(#a)'><path fill='#555' d='M0 0h40v20H0z'/><path fill='#007ec6' d='M40 0h68v20H40z'/><path fill='url(#b)' d='M0 0h108v20H0z'/></g><g fill='#fff' text-anchor='middle' font-family='DejaVu Sans,Verdana,Geneva,sans-serif' font-size='11'><text x='20' y='15' fill='#010101' fill-opacity='.3'>#{prefix}</text><text x='20' y='14'>#{prefix}</text><text x='73' y='15' fill='#010101' fill-opacity='.3'>Submitted</text><text x='73' y='14'>Submitted</text></g></svg>"
    when "review_pending"
      "<svg xmlns='http://www.w3.org/2000/svg' width='108' height='20'><linearGradient id='b' x2='0' y2='100%'><stop offset='0' stop-color='#bbb' stop-opacity='.1'/><stop offset='1' stop-opacity='.1'/></linearGradient><mask id='a'><rect width='108' height='20' rx='3' fill='#fff'/></mask><g mask='url(#a)'><path fill='#555' d='M0 0h40v20H0z'/><path fill='#007ec6' d='M40 0h68v20H40z'/><path fill='url(#b)' d='M0 0h108v20H0z'/></g><g fill='#fff' text-anchor='middle' font-family='DejaVu Sans,Verdana,Geneva,sans-serif' font-size='11'><text x='20' y='15' fill='#010101' fill-opacity='.3'>#{prefix}</text><text x='20' y='14'>#{prefix}</text><text x='73' y='15' fill='#010101' fill-opacity='.3'>Submitted</text><text x='73' y='14'>Submitted</text></g></svg>"
    when "under_review"
      "<svg xmlns='http://www.w3.org/2000/svg' width='129' height='20'><linearGradient id='b' x2='0' y2='100%'><stop offset='0' stop-color='#bbb' stop-opacity='.1'/><stop offset='1' stop-opacity='.1'/></linearGradient><mask id='a'><rect width='129' height='20' rx='3' fill='#fff'/></mask><g mask='url(#a)'><path fill='#555' d='M0 0h40v20H0z'/><path fill='#dfb317' d='M40 0h89v20H40z'/><path fill='url(#b)' d='M0 0h129v20H0z'/></g><g fill='#fff' text-anchor='middle' font-family='DejaVu Sans,Verdana,Geneva,sans-serif' font-size='11'><text x='20' y='15' fill='#010101' fill-opacity='.3'>#{prefix}</text><text x='20' y='14'>#{prefix}</text><text x='83.5' y='15' fill='#010101' fill-opacity='.3'>Under Review</text><text x='83.5' y='14'>Under Review</text></g></svg>"
    when "review_completed"
      "<svg xmlns='http://www.w3.org/2000/svg' width='150' height='20'><linearGradient id='b' x2='0' y2='100%'><stop offset='0' stop-color='#bbb' stop-opacity='.1'/><stop offset='1' stop-opacity='.1'/></linearGradient><mask id='a'><rect width='150' height='20' rx='3' fill='#fff'/></mask><g mask='url(#a)'><path fill='#555' d='M0 0h40v20H0z'/><path fill='#dfb317' d='M40 0h110v20H40z'/><path fill='url(#b)' d='M0 0h150v20H0z'/></g><g fill='#fff' text-anchor='middle' font-family='DejaVu Sans,Verdana,Geneva,sans-serif' font-size='11'><text x='20' y='15' fill='#010101' fill-opacity='.3'>#{prefix}</text><text x='20' y='14'>#{prefix}</text><text x='94' y='15' fill='#010101' fill-opacity='.3'>Review Complete</text><text x='94' y='14'>Review Complete</text></g></svg>"
    when "accepted"
      "<svg xmlns='http://www.w3.org/2000/svg' width='168' height='20'><linearGradient id='b' x2='0' y2='100%'><stop offset='0' stop-color='#bbb' stop-opacity='.1'/><stop offset='1' stop-opacity='.1'/></linearGradient><mask id='a'><rect width='168' height='20' rx='3' fill='#fff'/></mask><g mask='url(#a)'><path fill='#555' d='M0 0h39v20H0z'/><path fill='#4c1' d='M39 0h129v20H39z'/><path fill='url(#b)' d='M0 0h168v20H0z'/></g><g fill='#fff' text-anchor='middle' font-family='DejaVu Sans,Verdana,Geneva,sans-serif' font-size='11'><text x='19.5' y='15' fill='#010101' fill-opacity='.3'>#{prefix}</text><text x='19.5' y='14'>#{prefix}</text><text x='102.5' y='15' fill='#010101' fill-opacity='.3'>#{self.doi}</text><text x='102.5' y='14'>#{self.doi}</text></g></svg>"
    when "rejected"
      "<svg xmlns='http://www.w3.org/2000/svg' width='100' height='20'><linearGradient id='b' x2='0' y2='100%'><stop offset='0' stop-color='#bbb' stop-opacity='.1'/><stop offset='1' stop-opacity='.1'/></linearGradient><mask id='a'><rect width='100' height='20' rx='3' fill='#fff'/></mask><g mask='url(#a)'><path fill='#555' d='M0 0h40v20H0z'/><path fill='#e05d44' d='M40 0h60v20H40z'/><path fill='url(#b)' d='M0 0h100v20H0z'/></g><g fill='#fff' text-anchor='middle' font-family='DejaVu Sans,Verdana,Geneva,sans-serif' font-size='11'><text x='20' y='15' fill='#010101' fill-opacity='.3'>#{prefix}</text><text x='20' y='14'>#{prefix}</text><text x='69' y='15' fill='#010101' fill-opacity='.3'>Rejected</text><text x='69' y='14'>Rejected</text></g></svg>"
    else
      "<svg xmlns='http://www.w3.org/2000/svg' width='102' height='20'><linearGradient id='b' x2='0' y2='100%'><stop offset='0' stop-color='#bbb' stop-opacity='.1'/><stop offset='1' stop-opacity='.1'/></linearGradient><mask id='a'><rect width='102' height='20' rx='3' fill='#fff'/></mask><g mask='url(#a)'><path fill='#555' d='M0 0h40v20H0z'/><path fill='#9f9f9f' d='M40 0h62v20H40z'/><path fill='url(#b)' d='M0 0h102v20H0z'/></g><g fill='#fff' text-anchor='middle' font-family='DejaVu Sans,Verdana,Geneva,sans-serif' font-size='11'><text x='20' y='15' fill='#010101' fill-opacity='.3'>#{prefix}</text><text x='20' y='14'>#{prefix}</text><text x='70' y='15' fill='#010101' fill-opacity='.3'>Unknown</text><text x='70' y='14'>Unknown</text></g></svg>"
    end
  end

  def status_badge_url
    "#{Rails.application.settings["url"]}/papers/10.21105/#{joss_id}/status.svg"
  end

  def markdown_code
    "[![DOI](#{status_badge_url})](https://doi.org/#{doi})"
  end

private

  def set_sha
    self.sha ||= SecureRandom.hex
  end

  def set_last_activity
    self.last_activity = Time.now
  end
end
