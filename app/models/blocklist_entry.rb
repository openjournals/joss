# A submitter ORCID or a repository address (or repository owner) that is not
# allowed to submit new papers. Checked when a Paper is created.
#
# Repository values are stored without scheme, e.g. "github.com/owner/repo".
# An entry with only an owner, e.g. "github.com/owner", blocks every
# repository under that owner.
class BlocklistEntry < ApplicationRecord
  KINDS = %w[orcid repository].freeze
  ORCID_FORMAT = /\A\d{4}-\d{4}-\d{4}-\d{3}[\dX]\z/

  belongs_to :editor, optional: true

  before_validation :normalize_value

  validates :kind, inclusion: { in: KINDS }
  validates :value, presence: true, uniqueness: { scope: :kind, case_sensitive: false }
  validates :reason, presence: true
  validate :value_format

  scope :orcids, -> { where(kind: "orcid") }
  scope :repositories, -> { where(kind: "repository") }

  def self.normalize_orcid(value)
    value.to_s.strip.sub(/\Ahttps?:\/\/(www\.)?orcid\.org\//i, "").sub(/\/\z/, "").upcase
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

  # Matches an exact repository entry or any owner-level entry above it.
  def self.blocked_repository?(url)
    segments = normalize_repository(url).split("/")
    return false if segments.size < 2

    candidates = (2..segments.size).map { |n| segments.first(n).join("/") }
    repositories.where(value: candidates).exists?
  end

  def self.blocks_submission?(user:, repository_url:)
    (user.present? && blocked_orcid?(user.uid)) || blocked_repository?(repository_url)
  end

  def orcid?
    kind == "orcid"
  end

  def repository?
    kind == "repository"
  end

  def display_value
    orcid? ? value : "https://#{value}"
  end

  private

  def normalize_value
    self.value = orcid? ? self.class.normalize_orcid(value) : self.class.normalize_repository(value)
  end

  def value_format
    return if value.blank?

    if orcid? && !value.match?(ORCID_FORMAT)
      errors.add(:value, "is not a valid ORCID iD (expected 0000-0000-0000-0000)")
    elsif repository? && value.split("/").size < 2
      errors.add(:value, "must include at least a host and an owner, e.g. github.com/username")
    end
  end
end
