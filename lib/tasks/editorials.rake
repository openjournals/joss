namespace :editorials do
  desc "Send weekly emails to editors"
  task send_weekly_emails: :environment do
    # We run this task daily on Heroku but only want the email
    # sent once per week (on a Monday)
    if Time.now.monday?
      reviews_repo = Rails.application.settings["reviews"]
      review_issues = ReviewIssue.download_review_issues(reviews_repo)
      # Sort issues in place in order of date created

      pending_issues = review_issues.select { |i| i.editor == "Pending" }

      closed_issues = ReviewIssue.download_completed_reviews(reviews_repo)

      recently_closed_issues = closed_issues.select { |i| i.closed_at > 1.week.ago }

      # Loop through editors and send them their weekly email :-)
      Editor.active.each do |editor|
        editor_issues = ReviewIssue.review_issues_for_editor(review_issues, editor.login)
        Notifications.editor_weekly_email(editor, pending_issues, editor_issues, recently_closed_issues).deliver_now!
      end
    end
  end

  desc "Send twice-weekly emails with possible submission rejections"
  task send_query_scope_email: :environment do
    # We run this task daily on Heroku but only want the email
    # sent once per week (on a Monday)
    if Time.now.sunday?
      reviews_repo = Rails.application.settings["reviews"]
      review_issues = ReviewIssue.download_review_issues(reviews_repo, 'query-scope')

      # Loop through editors and send them their weekly email :-)
      Editor.active.each do |editor|
        Notifications.editor_scope_email(editor, review_issues).deliver_now!
      end
    end
  end
end
