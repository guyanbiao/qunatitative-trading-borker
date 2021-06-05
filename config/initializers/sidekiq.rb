require 'sidekiq'

redis_url = Rails.application.config_for(:redis)[:host]
# 'redis://redis.example.com:7372/0'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end