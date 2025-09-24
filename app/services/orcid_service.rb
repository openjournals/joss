require 'faraday'
require 'json'

class OrcidService
  ORCID_API_BASE = 'https://api.orcid.org/v3.0'
  
  def initialize(user = nil)
    @user = user
    @client = Faraday.new(url: ORCID_API_BASE) do |faraday|
      faraday.headers['Content-Type'] = 'application/vnd.orcid+json'
      faraday.adapter Faraday.default_adapter
    end
  end
  
  # Post a review as a peer review activity to a reviewer's ORCID profile
  def post_review_to_reviewer(reviewer, paper, review_url)
    return false unless reviewer.has_orcid_authentication?
    
    # Use the reviewer's personal OAuth token
    @client.headers['Authorization'] = "Bearer #{reviewer.user.oauth_token}"
    
    peer_review_data = build_peer_review_data(paper, review_url)
    response = @client.post("#{reviewer.orcid_id}/peer-reviews", peer_review_data.to_json)
    
    response.success?
  end
  
  private
  
  def build_peer_review_data(paper, review_url)
    {
      "reviewer-role" => "reviewer",
      "review-url" => {
        "value" => review_url
      },
      "review-type" => "review",
      "review-completion-date" => {
        "year" => {
          "value" => paper.accepted_at&.year.to_s
        },
        "month" => {
          "value" => paper.accepted_at&.month.to_s
        },
        "day" => {
          "value" => paper.accepted_at&.day.to_s
        }
      },
      "review-group-id" => "journal-of-open-source-software",
      "subject-external-identifier" => {
        "external-id-type" => "doi",
        "external-id-value" => paper.doi,
        "external-id-url" => {
          "value" => "https://doi.org/#{paper.doi}"
        },
        "external-id-relationship" => "self"
      },
      "subject-container-name" => {
        "value" => "Journal of Open Source Software"
      },
      "subject-name" => {
        "title" => {
          "value" => paper.title
        }
      },
      "subject-type" => "software"
    }
  end
end
