class Notifications < ApplicationMailer
  EDITOR_EMAILS = [Rails.application.settings["editor_email"]]

  def submission_email(paper)
    @url  = "#{Rails.application.settings["url"]}/papers/#{paper.sha}"
    @paper = paper
    mail(to: EDITOR_EMAILS, subject: "New submission: #{paper.title}")
  end

  def editor_invite_email(paper, editor)
    @paper = paper
    mail(to: editor.email, subject: "JOSS editorial invite: #{paper.title}")
  end

  def author_submission_email(paper)
    @url  = "#{Rails.application.settings["url"]}/papers/#{paper.sha}"
    @paper = paper
    mail(to: paper.submitting_author.email, subject: "Thanks for your submission: #{paper.title}")
  end

  def editor_weekly_email(editor, pending_issues, assigned_issues, recently_closed_issues)
    @pending_issues = pending_issues
    @assigned_issues = assigned_issues
    @closed_issues = recently_closed_issues
    @editor = editor.login
    mail(to: editor.email, subject: "#{Rails.application.settings["abbreviation"]} weekly editor update for #{editor.login}")
  end

  def editor_scope_email(editor, issues)
    @query_scope_issues = issues
    @editor = editor
    mail(to: editor.email, subject: "[Please review]: #{Rails.application.settings["abbreviation"]} scope check summary")
  end
end
