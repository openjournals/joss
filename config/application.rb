require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Joss
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    attr_accessor :settings
    self.settings = YAML.load_file(Rails.root.join("config/settings-#{Rails.env}.yml")).with_indifferent_access

    config.assets.precompile += %w(*.svg *.eot *.woff *.ttf)
    config.autoload_paths += [
      "#{config.root}/lib"
    ]
    config.eager_load_paths += [
      "#{config.root}/lib"
    ]
  end
end
