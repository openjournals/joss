module SettingsHelper
  def setting(*paths)
    Rails.application.settings.dig(*paths).html_safe
  end
end
