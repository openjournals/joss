# This is a Helper Class to make it easier to filter/select review issues from
# GitHub.

class ReviewIssue
  # Download all of the current open issues on review repo
  def self.download_review_issues(review_repo)
    open_issues = GITHUB.list_issues(review_repo, state: 'open')

    # TODO: Generate some stats on recently closed issues too
    # closed_issues = github.list_issues(@nwo, :state => 'closed')

    # Loop through open issues and create ReviewIssues for future manipulation
    review_issues = []

    open_issues.each do |issue|
      next if issue.labels.collect(&:name).include?('paused')
      if issue.title =~ /\[PRE REVIEW\]/
        review_issues << ReviewIssue.new(issue, state = 'open')
      elsif issue.title =~ /\[REVIEW\]/
        review_issues << ReviewIssue.new(issue, state = 'open')
      else
        Rails.logger.info("Failing to initialize issue: #{issue.title} (#{issue.number})")
      end
    end

    return review_issues.sort_by!(&:created_at)
  end

  # Download all the completed (closed) review issues
  def self.download_completed_reviews(review_repo)
    complete_issues = GITHUB.list_issues(review_repo, state: 'closed')

    # Loop through open issues and create ReviewIssues for future manipulation
    review_issues = []

    complete_issues.each do |issue|
      if issue.title =~ /\[REVIEW\]/
        review_issues << ReviewIssue.new(issue, state = 'closed')
      end
    end

    return review_issues.sort_by!(&:closed_at)
  end

  # Filter the review issues for editor
  def self.review_issues_for_editor(review_issues, editor)
    editor_issues = []
    review_issues.each do |issue|
      next unless issue.body =~ /\*\*Editor:\*\*\s*(@\S*|Pending)/i
      next unless issue.editor.casecmp(editor['login'].downcase).zero?
      comments = GITHUB.issue_comments(ENV['REVIEW_REPO'], issue.number)
      issue.last_comment = comments.last
      issue.comment_count = comments.count
      editor_issues << issue
    end

    return editor_issues
  end

  attr_accessor :title, :body, :comments, :labels, :state, :open, :number, :created_at,
                :closed_at, :comment_count, :last_comment

  def initialize(raw_issue, state)
    @title = raw_issue['title']
    @body = raw_issue['body']
    @number = raw_issue['number']
    @created_at = raw_issue['created_at']
    @closed_at = raw_issue['closed_at']
    @state = state
  end

  # Is this a 'PRE REVIEW' issue?
  def pre_review?
    title.match(/\[PRE REVIEW\]/)
  end

  # Extract the Editor from the issue body
  def editor
    body.match(/\*\*Editor:\*\*\s*(@\S*|Pending)/i)[1]
  end

  # Extract the Reviewer from the issue body
  def reviewer
    body.match(/\*\*Reviewer:\*\*\s*(@\S*|Pending)/i)[1]
  end
end
