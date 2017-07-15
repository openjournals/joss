class User < ActiveRecord::Base
  has_many :papers

  before_create :set_sha

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid      = auth.uid
      user.name     = auth.info.name
      user.extra = auth
      user.email = auth.info.email
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at) if auth['provider'] == 'facebook'
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
      return 'Missing Name'
    end
  end

  def orcid_url
    'http://orcid.org/' + uid
  end

  def profile_complete?
    email.present? && github_username.present?
  end

  private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
