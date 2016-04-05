require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Forms
  class Application < Rails::Application
    config.action_view.default_form_builder = 'ModelFormBuilder'
    config.action_view.field_error_proc = Proc.new do |html_tag|
      html_tag.html_safe
    end
    config.action_mailer.default_url_options = { host: ENV['HOST'] || "localhost:#{ ENV['PORT'] || 3000 }" }
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
