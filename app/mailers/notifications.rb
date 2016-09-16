class Notifications < ApplicationMailer
  EDITOR_EMAILS = ["joss.theoj@gmail.com "]

  def submission_email(paper)
    @url  = "http://joss.theoj.org/papers/#{paper.sha}"
    @paper = paper
    mail(:to => EDITOR_EMAILS, :subject => "New submission: #{paper.title}")
  end
end
