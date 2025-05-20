require 'sidekiq'
require 'sidekiq-scheduler'

redis_config = { 
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
  password: ENV.fetch('REDIS_PASSWORD', nil)
}

  Sidekiq.configure_server do |config|
  config.redis = redis_config
  
  # Load the schedule
  config.on(:startup) do
    schedule_file = Rails.root.join('config', 'sidekiq_schedule.yml')
    
    if File.exist?(schedule_file)
      Sidekiq::Scheduler.enabled = true
      Sidekiq::Scheduler.dynamic = true
      Sidekiq.schedule = YAML.load_file(schedule_file)
      Sidekiq::Scheduler.reload_schedule!
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end