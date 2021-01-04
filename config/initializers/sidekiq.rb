Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL_SIDEKIQ", "redis://localhost:6379/1") }
  Rails.logger = Sidekiq.logger
end

Sidekiq.configure_client { |config| config.redis = { url: ENV.fetch("REDIS_URL_SIDEKIQ", "redis://localhost:6379/1") } }
