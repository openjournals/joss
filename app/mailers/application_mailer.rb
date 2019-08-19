class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.settings["noreply_email"]
  layout 'mailer'
end
