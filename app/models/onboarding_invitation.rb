class OnboardingInvitation < ApplicationRecord
  validates :email, presence: true
  validates_uniqueness_of :email, message: "already present in the list on sent invitations"
  validates :token, presence: true, uniqueness: true

  before_validation :set_token, on: :create
  before_validation :strip_email
  after_create :send_email

  def send_email
    Notifications.onboarding_invitation_email(self).deliver_now
    self.touch(:last_sent_at)
  end

  private

  def set_token
    self.token ||= SecureRandom.hex(5)
  end

  def strip_email
    self.email = self.email.strip if self.email
  end
end
