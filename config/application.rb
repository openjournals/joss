require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Joss
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    attr_accessor :settings
    self.settings = YAML.load_file(Rails.root.join("config/settings-#{Rails.env}.yml")).with_indifferent_access

    config.assets.precompile += %w(*.svg *.eot *.woff *.ttf)
    config.autoload_paths += [
      "#{config.root}/lib"
    ]
    config.eager_load_paths += [
      "#{config.root}/lib"
    ]

    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
