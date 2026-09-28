module JournalFeatures
  def self.tracks?
    return !!Rails.application.settings.dig(:features, :tracks)
  end

  # The SUBMISSIONS_OPEN env var (e.g. a Heroku config var) overrides the settings file,
  # so submissions can be switched without a deploy. Otherwise open unless explicitly false.
  def self.submissions_open?
    override = ENV["SUBMISSIONS_OPEN"].to_s.strip.downcase
    return %w(true 1 yes).include?(override) unless override.empty?
    return Rails.application.settings.dig(:features, :submissions_open) != false
  end
end
