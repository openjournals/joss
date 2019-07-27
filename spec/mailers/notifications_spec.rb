require "rails_helper"

describe Notifications, :type => :mailer do
  it "should include the idea text in the body" do
    paper = create(:paper, :title => "Nice paper!")
    mail = Notifications.submission_email(paper)

    expect(mail.subject).to match /Nice paper/
  end

  it "should tell the submitting author to chill out" do
    paper = create(:paper, :title => "Nice paper!")
    mail = Notifications.author_submission_email(paper)

    expect(mail.text_part.body).to match /is currently awaiting triage by our managing editor/
  end
end
