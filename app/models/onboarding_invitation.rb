# == Schema Information
#
# Table name: onboarding_invitations
#
#  id                 :bigint           not null, primary key
#  accepted_at        :datetime
#  email              :string
#  invited_to_team_at :datetime
#  last_sent_at       :datetime
#  name               :string
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  editor_id          :bigint
#
# Indexes
#
#  index_onboarding_invitations_on_editor_id        (editor_id)
#  index_onboarding_invitations_on_token            (token)
#  index_onboarding_invitations_on_token_and_email  (token,email)
#
class OnboardingInvitation < ApplicationRecord
  belongs_to :editor, optional: true

  validates :email, presence: true
  validates_uniqueness_of :email, message: "is already present in the list on sent invitations"
  validates :token, presence: true, uniqueness: true

  before_validation :set_token, on: :create
  before_validation :strip_email
  after_create :send_email

  scope :pending_acceptance, -> { where(accepted_at: nil) }

  def send_email
    Notifications.onboarding_invitation_email(self).deliver_now
    self.touch(:last_sent_at)
  end

  def accepted?
    self.accepted_at.present?
  end

  def invited_to_team?
    self.invited_to_team_at.present?
  end

  def accepted!(ed = nil)
    self.update(editor: ed, accepted_at: Time.now)
  end

  def invited_to_team!
    self.touch(:invited_to_team_at)
  end

  private

  def set_token
    self.token ||= SecureRandom.hex(5)
  end

  def strip_email
    self.email = self.email.strip if self.email
  end
end
