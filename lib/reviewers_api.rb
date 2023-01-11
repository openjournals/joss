module ReviewersApi

  def self.api_configured?
    ENV["REVIEWERS_HOST_URL"].present? && ENV["REVIEWERS_API_TOKEN"].present?
  end

  def self.assign_reviewer(reviewer, issue_id)
    return false unless ReviewersApi.api_configured? && reviewer.present?

    url = "#{ENV['REVIEWERS_HOST_URL']}/api/stats/update/#{reviewer}/review_assigned"
    idempotency_key = "assign-#{reviewer}-#{issue_id}"

    response = Faraday.post(url, { idempotency_key: idempotency_key }, { "TOKEN" => ENV["REVIEWERS_API_TOKEN"] })

    if response.status.between?(400, 599)
      Rails.logger.warn("Error assigning review #{issue_id} to #{reviewer}: Got response code #{response.status}")
    end

    response.status.between?(200, 299)
  end

  def self.unassign_reviewer(reviewer, issue_id)
    return false unless ReviewersApi.api_configured? && reviewer.present?

    url = "#{ENV['REVIEWERS_HOST_URL']}/api/stats/update/#{reviewer}/review_unassigned"
    idempotency_key = "unassign-#{reviewer}-#{issue_id}"

    response = Faraday.post(url, { idempotency_key: idempotency_key }, { "TOKEN" => ENV["REVIEWERS_API_TOKEN"] })

    if response.status.between?(400, 599)
      Rails.logger.warn("Error unassigning #{reviewer} from review #{issue_id}: Got response code #{response.status}")
    end

    response.status.between?(200, 299)
  end

  def self.assign_reviewers(reviewers, issue_id)
    return false unless ReviewersApi.api_configured?

    reviewers_list = []
    if reviewers.is_a?(String)
      reviewers_list = reviewers.split(',').each(&:strip!)
    elsif reviewers.is_a?(Array)
      reviewers_list = reviewers.each(&:strip!)
    end

    reviewers_list.each do |reviewer|
      ReviewersApi.assign_reviewer(reviewer, issue_id)
    end

  rescue
    Rails.logger.warn("Error calling ReviewersAPI assigning #{reviewers} to issue #{issue_id}")
  end

  def self.unassign_reviewers(reviewers, issue_id)
    return false unless ReviewersApi.api_configured?

    reviewers_list = []
    if reviewers.is_a?(String)
      reviewers_list = reviewers.split(',').each(&:strip!)
    elsif reviewers.is_a?(Array)
      reviewers_list = reviewers.each(&:strip!)
    end

    reviewers_list.each do |reviewer|
      ReviewersApi.unassign_reviewer(reviewer, issue_id)
    end

  rescue
    Rails.logger.warn("Error calling ReviewersAPI unassigning #{reviewers} from issue #{issue_id}")
  end

end