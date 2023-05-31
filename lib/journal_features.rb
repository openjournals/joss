module JournalFeatures
  def self.tracks?
    return !!Rails.application.settings.dig(:features, :tracks)
  end
end
