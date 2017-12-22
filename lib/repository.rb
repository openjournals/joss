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
end
