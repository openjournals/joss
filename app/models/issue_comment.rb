# One row per comment received via the GitHub webhook on a pre-review or
# review issue. Used by the AEiC dashboard to spot accounts commenting on
# many issues they have no role in (e.g. spammy "I can review" offers).
class IssueComment < ApplicationRecord
  ROLES = %w[bot editor author reviewer none].freeze
  KINDS = %w[pre-review review].freeze
  WINDOWS = [1, 7, 30].freeze
  DEFAULT_WINDOW = 7

  belongs_to :paper

  validates :login, :issue_id, :commented_at, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :role, inclusion: { in: ROLES }

  scope :since, -> (time) { where("issue_comments.commented_at >= ?", time) }
  scope :by_track, -> (track_id) { joins(:paper).where(papers: { track_id: track_id }) }
  scope :for_login, -> (login) { where("lower(issue_comments.login) = ?", login.to_s.downcase) }
  scope :excluding_staff, -> {
    where.not(role: %w[bot editor])
      .where("lower(issue_comments.login) NOT IN (SELECT lower(login) FROM editors WHERE login IS NOT NULL)")
  }

  # Work out which hat the commenter was wearing at the time of the comment.
  def self.role_for(login, paper)
    handle = normalize(login)
    return "bot" if handle == normalize(Rails.application.settings["bot_username"])
    return "editor" if Editor.where("lower(login) = ?", handle).exists?
    return "author" if handle == normalize(paper.submitting_author&.github_username)
    return "reviewer" if paper.reviewers.to_a.any? { |r| normalize(r) == handle }
    "none"
  end

  def self.normalize(handle)
    handle.to_s.strip.sub(/\A@/, "").downcase
  end

  # Non-editor, non-bot logins ranked by the number of distinct issues they
  # have commented on in the window. Each row responds to:
  #   login, issues_count, comments_count, no_role_issues_count, last_commented_at
  def self.leaderboard(since:, track_id: nil, limit: 100)
    scope = since(since).excluding_staff
    scope = scope.by_track(track_id) if track_id.present?

    scope.group("issue_comments.login")
         .select("issue_comments.login AS login",
                 "COUNT(DISTINCT issue_comments.issue_id) AS issues_count",
                 "COUNT(*) AS comments_count",
                 "COUNT(DISTINCT CASE WHEN issue_comments.role = 'none' THEN issue_comments.issue_id END) AS no_role_issues_count",
                 "MAX(issue_comments.commented_at) AS last_commented_at")
         .order("issues_count DESC, no_role_issues_count DESC, comments_count DESC, login ASC")
         .limit(limit)
  end

  def github_issue_url
    "https://github.com/#{Rails.application.settings["reviews"]}/issues/#{issue_id}"
  end
end
