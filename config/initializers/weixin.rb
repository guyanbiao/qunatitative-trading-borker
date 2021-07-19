
redis_url = Rails.application.config_for(:redis)[:host]

redis = Redis.new(url: redis_url)

WeixinAuthorize.configure do |config|
  config.redis = redis
  # config.key_expired = 200
  config.rest_client_options = {timeout: 10, open_timeout: 10, verify_ssl: true}
end