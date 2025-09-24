class Reviewer < ApplicationRecord
  validates :github_username, presence: true, uniqueness: true
  
  belongs_to :user, optional: true
  
  # Normalize GitHub username to remove @ prefix
  normalizes :github_username, with: -> username { username.gsub(/^@/, '') }
  
  def orcid_url
    return nil unless user&.uid.present?
    "https://orcid.org/#{user.uid}"
  end
  
  def orcid_id
    user&.uid
  end
  
  def has_orcid_authentication?
    user&.provider == 'orcid' && user&.oauth_token.present?
  end
  
  def display_name
    name.present? ? name : github_username
  end
  
  def self.find_or_create_by_github(github_username)
    normalized_username = github_username.gsub(/^@/, '')
    find_or_create_by(github_username: normalized_username)
  end
  
  def self.find_or_create_by_user(user)
    return nil unless user.github_username.present?
    
    find_or_create_by(github_username: user.github_username) do |reviewer|
      reviewer.user = user
      reviewer.name = user.name
      reviewer.email = user.email
    end
  end
end
