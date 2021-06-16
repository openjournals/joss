module Repository
  def self.config
    return @config if @config
    YAML.load_file(Rails.root.join("config/repository.yml"))
  end

  def self.nwo
    config.keys.first
  end

  def self.papers
    config[nwo]["papers"]
  end

  def self.editors
    Rails.cache.fetch("repository.editors", expires_in: 3.hours) do
      GITHUB.team_members(config[nwo]["editor_team_id"]).collect { |e| "@#{e.login}" }.sort
    end
  end

  def self.invite_to_editors_team(editor_handle)
    invitee_id = begin
      Octokit.user(editor_handle).id
    rescue Octokit::NotFound
      nil
    end

    if invitee_id.present?
      org = Rails.application.settings["reviews"].split("/").first
      url = "https://api.github.com/orgs/#{org}/invitations"
      headers = {"Authorization" => "token #{ENV['GH_TOKEN']}", "Content-Type" => "application/json", "Accept" => "application/vnd.github.v3+json"}
      parameters = {invitee_id: invitee_id, team_ids: [config[nwo]["editor_team_id"]]}

      response = Faraday.post(url, parameters.to_json, headers)
      response.status.between?(200, 299)
    else
      false
    end
  end
end
