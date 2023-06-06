# frozen_string_literal: true

# Default page size
Pagy::DEFAULT[:items] = 20

# No page links
Pagy::DEFAULT[:size] = []

require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page


# Elasticsearch Rails extra: Paginate `ElasticsearchRails::Results` objects
# See https://ddnexus.github.io/pagy/docs/extras/elasticsearch_rails
# Default :pagy_search method: change only if you use also
# the searchkick or meilisearch extra that defines the same
# Pagy::DEFAULT[:elasticsearch_rails_pagy_search] = :pagy_search
# Default original :search method called internally to do the actual search
# Pagy::DEFAULT[:elasticsearch_rails_search] = :search
# require 'pagy/extras/elasticsearch_rails'


# Searchkick extra: Paginate `Searchkick::Results` objects
# See https://ddnexus.github.io/pagy/docs/extras/searchkick
# Default :pagy_search method: change only if you use also
# the elasticsearch_rails or meilisearch extra that defines the same
# DEFAULT[:searchkick_pagy_search] = :pagy_search
# Default original :search method called internally to do the actual search
Pagy::DEFAULT[:searchkick_search] = :search
require 'pagy/extras/searchkick'
# uncomment if you are going to use Searchkick.pagy_search
# Searchkick.extend Pagy::Searchkick

# Rails
# Enable the .js file required by the helpers that use javascript
# (pagy*_nav_js, pagy*_combo_nav_js, and pagy_items_selector_js)
# See https://ddnexus.github.io/pagy/docs/api/javascript

# With the asset pipeline
# Sprockets need to look into the pagy javascripts dir, so add it to the assets paths
# Rails.application.config.assets.paths << Pagy.root.join('javascripts')

# I18n
Pagy::I18n.load(locale: "en", filepath: File.join(Rails.root, "config", "locales", "en.yml"))

# When you are done setting your own default freeze it, so it will not get changed accidentally
Pagy::DEFAULT.freeze



