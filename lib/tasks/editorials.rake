namespace :editorials do
  desc 'Send weekly emails to editors'
  task send_weekly_emails: :environment do
    # We run this task daily on Heroku but only want the email
    # sent once per week (on a Sunday)
    if Time.now.sunday?
      review_issues = ReviewIssue.download_review_issues(ENV['REVIEW_REPO'])
      # Sort issues in place in order of date created

      pending_issues = review_issues.select { |i| i.editor == 'Pending' }

      closed_issues = ReviewIssue.download_completed_reviews(ENV['REVIEW_REPO'])

      recently_closed_issues = closed_issues.select { |i| i.closed_at > 1.week.ago }

      # Loop through editors and send them their weekly email :-)
      YAML.safe_load(ENV['EDITORS']).each do |editor|
        editor_issues = ReviewIssue.review_issues_for_editor(review_issues, editor)
        Notifications.editor_weekly_email(editor, pending_issues, editor_issues, recently_closed_issues).deliver_now!
      end
    end
  end
end
