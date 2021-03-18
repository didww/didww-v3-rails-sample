# frozen_string_literal: true

Sentry.init do |config|
  config.logger = Rails.logger
  config.async = lambda do |event, hint|
    Sentry::SendEventJob.perform_later(event, hint)
  end
  # https://devcenter.heroku.com/articles/dyno-metadata
  config.server_name = ENV['HEROKU_APP_NAME']
  config.environment = Rails.env.production? ? 'staging' : 'development'
  config.release = ENV['HEROKU_RELEASE_VERSION'] || 'unknown'
  config.enabled_environments = %w[staging]
  config.excluded_exceptions += [
    'ActionController::RoutingError',
    'ActiveRecord::RecordNotFound'
  ]
end
Sentry.configure_scope do |scope|
  scope.set_tags(
    rails_env: Rails.env.to_s,
    didww_api_url: ENV['DIDWW_API_URL']
  )
  scope.set_extras(
    commit: ENV['HEROKU_SLUG_COMMIT'],
    deployed_at: ENV['HEROKU_RELEASE_CREATED_AT']
  )
end
