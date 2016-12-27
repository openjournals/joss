class Notifications < ApplicationMailer
  EDITOR_EMAILS = ["joss.theoj@gmail.com "]

  def submission_email(paper)
    @url  = "http://joss.theoj.org/papers/#{paper.sha}"
    @paper = paper
    mail(:to => EDITOR_EMAILS, :subject => "New submission: #{paper.title}")
  end

  def editor_weekly_email(editor, pending_issues, assigned_issues)
    @pending_issues = pending_issues
    @assigned_issues = assigned_issues
    mail(:to => editor["email"], :subject => "JOSS weekly editor update for #{editor['login']}")
  end
end
