require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

module SalesContext
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # API-only application
    config.api_only = true

    # Autoload lib directory
    config.autoload_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('lib')

    # Use UUIDs as primary keys
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
end
