# A submitter ORCID, email address, or a repository address (or repository
# owner) that is not allowed to submit new papers. Checked when a Paper is
# created.
#
# Repository values are stored without scheme, e.g. "github.com/owner/repo".
# An entry with only an owner, e.g. "github.com/owner", blocks every
# repository under that owner. Email values are exact addresses, stored
# lowercased; whole domains are deliberately not supported.
class BlocklistEntry < ApplicationRecord
  KINDS = %w[orcid email repository].freeze
  ORCID_FORMAT = /\A\d{4}-\d{4}-\d{4}-\d{3}[\dX]\z/
  EMAIL_FORMAT = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  belongs_to :editor, optional: true

  before_validation :normalize_value

  validates :kind, inclusion: { in: KINDS }
  validates :value, presence: true, uniqueness: { scope: :kind, case_sensitive: false }
  validates :reason, presence: true
  validate :value_format

  scope :orcids, -> { where(kind: "orcid") }
  scope :emails, -> { where(kind: "email") }
  scope :repositories, -> { where(kind: "repository") }

  def self.normalize_orcid(value)
    value.to_s.strip.sub(/\Ahttps?:\/\/(www\.)?orcid\.org\//i, "").sub(/\/\z/, "").upcase
  end

  def self.normalize_email(value)
    value.to_s.strip.downcase
  end

  def self.normalize_repository(value)
    value.to_s.strip.downcase
         .sub(/\Ahttps?:\/\//, "")
         .sub(/\Awww\./, "")
         .sub(/\/+\z/, "")
         .sub(/\.git\z/, "")
         .sub(/\/+\z/, "")
  end

  # "github.com/owner/repo" => "github.com/owner"; nil if there is no owner part.
  def self.repository_owner(value)
    segments = normalize_repository(value).split("/")
    return nil if segments.size < 2
    segments.first(2).join("/")
  end

  def self.blocked_orcid?(orcid)
    normalized = normalize_orcid(orcid)
    return false if normalized.blank?
    orcids.where(value: normalized).exists?
  end

  def self.blocked_email?(email)
    normalized = normalize_email(email)
    return false unless normalized.match?(EMAIL_FORMAT)

    emails.where(value: normalized).exists?
  end

  # Matches an exact repository entry or any owner-level entry above it.
  def self.blocked_repository?(url)
    segments = normalize_repository(url).split("/")
    return false if segments.size < 2

    candidates = (2..segments.size).map { |n| segments.first(n).join("/") }
    repositories.where(value: candidates).exists?
  end

  def self.blocks_submission?(user:, repository_url:)
    return true if user.present? && (blocked_orcid?(user.uid) || blocked_email?(user.email))
    blocked_repository?(repository_url)
  end

  # Everything about a paper's submitter that can be blocked, as [kind, value]
  # pairs: their ORCID iD, their email, and the repository owner (or the exact
  # repository if the URL has no owner segment). Blank values are omitted.
  def self.candidates_for(paper)
    author = paper.submitting_author
    repo = repository_owner(paper.repository_url) || normalize_repository(paper.repository_url)

    [
      ["orcid", author&.uid],
      ["email", author&.email],
      ["repository", repo]
    ].reject { |_, value| value.blank? }
  end

  # Block every candidate for the paper that isn't already blocked.
  # Returns [created_entries, failed_entries].
  def self.block_all_for(paper, editor:, reason:)
    created = []
    failed = []

    candidates_for(paper).each do |kind, value|
      already = case kind
                when "orcid" then blocked_orcid?(value)
                when "email" then blocked_email?(value)
                else blocked_repository?(value)
                end
      next if already

      entry = new(kind: kind, value: value, reason: reason, editor: editor)
      (entry.save ? created : failed) << entry
    end

    [created, failed]
  end

  def orcid?
    kind == "orcid"
  end

  def email?
    kind == "email"
  end

  def repository?
    kind == "repository"
  end

  def display_value
    repository? ? "https://#{value}" : value
  end

  def kind_label
    case kind
    when "orcid" then "ORCID iD"
    when "email" then "Email"
    else "Repository"
    end
  end

  private

  def normalize_value
    self.value = case kind
                 when "orcid" then self.class.normalize_orcid(value)
                 when "email" then self.class.normalize_email(value)
                 else self.class.normalize_repository(value)
                 end
  end

  def value_format
    return if value.blank?

    if orcid? && !value.match?(ORCID_FORMAT)
      errors.add(:value, "is not a valid ORCID iD (expected 0000-0000-0000-0000)")
    elsif email? && !value.match?(EMAIL_FORMAT)
      errors.add(:value, "must be a full email address")
    elsif repository? && value.split("/").size < 2
      errors.add(:value, "must include at least a host and an owner, e.g. github.com/username")
    end
  end
end
