require "rails_helper"

describe Notifications, type: :mailer do
  before { skip_paper_repo_url_check }

  it "should include the idea text in the body" do
    paper = create(:paper, title: "Nice paper!")
    mail = Notifications.submission_email(paper)

    expected_recipients = [paper.track.aeic_emails + Notifications::EDITOR_EMAILS].flatten
    expect(mail.subject).to match /Nice paper/
    expect(mail.recipients).to match_array expected_recipients
  end

  it "should tell the submitting author to chill out" do
    paper = create(:paper, title: "Nice paper!")
    mail = Notifications.author_submission_email(paper)

    expect(mail.text_part.body).to match /is currently awaiting triage by our managing editor/
  end

  it "should warn authors not to reply to the email" do
    paper = create(:paper, title: "Nice paper!")
    mail = Notifications.author_submission_email(paper)

    expect(mail.text_part.body).to match /Please do not reply to this email/
    expect(mail.text_part.body).to match /admin@theoj\.org.*is unmonitored/
    expect(mail.text_part.body).to match /GitHub issue will be opened/
  end
end
