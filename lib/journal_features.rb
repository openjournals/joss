module JournalFeatures
  def self.tracks?
    return !!Rails.application.settings.dig(:features, :tracks)
  end

  # Open unless explicitly set to false, so a missing key keeps the form available
  def self.submissions_open?
    return Rails.application.settings.dig(:features, :submissions_open) != false
  end
end
