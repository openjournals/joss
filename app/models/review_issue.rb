# This is a Helper Class to make it easier to filter/select review issues from
# GitHub.

class ReviewIssue

  # Download all of the current open issues on review repo
  def self.download_review_issues(review_repo)
    open_issues = GITHUB.list_issues(review_repo, :state => 'open')

    # TODO: Generate some stats on recently closed issues too
    # closed_issues = github.list_issues(@nwo, :state => 'closed')

    # Loop through open issues and create ReviewIssues for future manipulation
    review_issues = []

    open_issues.each do |issue|
      next if issue.labels.collect {|l| l.name }.include?('paused')
      if issue.title.match(/\[PRE REVIEW\]/)
        review_issues << ReviewIssue.new(issue, state="open")
      elsif issue.title.match(/\[REVIEW\]/)
        review_issues << ReviewIssue.new(issue, state="open")
      else
        Rails.logger.info("Failing to initialize issue: #{issue.title} (#{issue.number})")
      end
    end

    return review_issues.sort_by! {|i| i.created_at }
  end

  # Download all the completed (closed) review issues
  def self.download_completed_reviews(review_repo)
    complete_issues = GITHUB.list_issues(review_repo, :state => 'closed')

    # Loop through open issues and create ReviewIssues for future manipulation
    review_issues = []

    complete_issues.each do |issue|
      if issue.title.match(/\[REVIEW\]/)
        labels = issue.labels.collect(&:name)
        next if labels.include?('withdrawn')
        next if labels.include?('rejected')

        review_issues << ReviewIssue.new(issue, state="closed")
      end
    end

    return review_issues.sort_by! {|i| i.closed_at }
  end

  # Filter the review issues for editor
  def self.review_issues_for_editor(review_issues, editor_login)
    editor_issues = []
    review_issues.each do |issue|
      if issue.body.match(/\*\*Editor:\*\*\s*(@\S*|Pending)/i)
        if issue.editor.downcase == "@#{editor_login.downcase}"
          comments = GITHUB.issue_comments(Rails.application.settings["reviews"], issue.number)
          issue.last_comment = comments.last
          issue.comment_count = comments.count
          editor_issues << issue
        end
      end
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
