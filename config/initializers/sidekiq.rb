require "sidekiq"
require "sidekiq-scheduler"
require "sidekiq-unique-jobs"

begin
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
    config.on(:startup) do
      schedule_file = "config/sidekiq_scheduler.yml"

      if File.exist?(schedule_file)
        Sidekiq.schedule = YAML.load_file(schedule_file)
        Sidekiq::Scheduler.reload_schedule!
      end
    end
  end

  SidekiqUniqueJobs.configure do |unique_config|
    unique_config.logger = Rails.logger
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
  end

  puts "[Sidekiq Init] Initializer loaded!"

rescue => e
  puts "[Sidekiq Init] Failed to configure Sidekiq: #{e.message}"
end
