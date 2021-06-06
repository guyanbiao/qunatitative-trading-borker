require 'sidekiq'
require 'sidekiq-scheduler'

redis_url = Rails.application.config_for(:redis)[:host]
# 'redis://redis.example.com:7372/0'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  config.on(:startup) do
    sidekiq_scheduler_config =
      YAML.load_file(Rails.root.join('config/sidekiq_scheduler.yml'))
    Sidekiq.schedule = sidekiq_scheduler_config
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

Sidekiq.logger.level = Logger::DEBUG
