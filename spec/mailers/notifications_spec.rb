require 'rails_helper'

describe Notifications, type: :mailer do
  it 'should include the idea text in the body' do
    paper = create(:paper, title: 'Nice paper!')
    mail = Notifications.submission_email(paper)

    expect(mail.subject).to match /Nice paper/
  end
end
