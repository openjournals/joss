# frozen_string_literal: true

Rails.application.configure do
  config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]

  config.i18n.available_locales = [
    :en,
    :es,
    :nb,
    :pl,
  ]

  config.i18n.default_locale = begin
                                 custom_default_locale = ENV['DEFAULT_LOCALE']&.to_sym

                                 if Rails.configuration.i18n.available_locales.include?(custom_default_locale)
                                   custom_default_locale
                                 else
                                   :en
                                 end
                               end

end
