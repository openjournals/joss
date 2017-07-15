require 'omniauth-orcid'

Rails.application.config.middleware.use OmniAuth::Builder do
  environment = defined?(Rails) ? Rails.env : ENV['RACK_ENV']
  path = File.join(Rails.root, 'config', 'orcid.yml')
  settings = YAML.safe_load(ERB.new(File.new(path).read).result)[environment]

  # Make parameters available elsewhere in the app
  Rails.configuration.orcid = settings

  # Initialize the OAuth connection
  provider :orcid, settings['client_id'], settings['client_secret'],
           authorize_params: {
             scope: '/authenticate'
           },
           client_options: {
             site: settings['site'],
             authorize_url: settings['authorize_url'],
             token_url: settings['token_url']
           }
end
