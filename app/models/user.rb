# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  admin            :boolean          default(FALSE)
#  email            :string
#  extra            :hstore
#  github_username  :string
#  name             :string
#  oauth_expires_at :string
#  oauth_token      :string
#  provider         :string
#  sha              :string
#  uid              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email)
#  index_users_on_name   (name)
#  index_users_on_sha    (sha)
#
class User < ApplicationRecord

  has_many :papers
  has_one :editor

  before_create :set_sha

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid      = auth.uid
      user.name     = auth.info.name
      user.extra = auth
      user.email = auth.info.email
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at) if (auth.credentials.expires && auth.credentials.expires_at.present?)
      user.save
    end
  end

  def to_param
    sha
  end

  def nice_name
    if name
      return name.split(',').collect(&:strip).reverse.join(' ')
    else
      return "Missing Name"
    end
  end

  def is_owner_of?(paper)
    paper.submitting_author == self
  end

  def orcid_url
    "http://orcid.org/" + uid
  end

  def profile_complete?
    email.present? && github_username.present?
  end

  def editor?
    self.editor ? true : false
  end

  def aeic?
    editor? && self.editor.board?
  end

  def pretty_github_username
    if github_username.start_with?('@')
      return github_username
    else
      return github_username.prepend('@')
    end
  end

private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
