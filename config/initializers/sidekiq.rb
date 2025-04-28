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
    config.death_handlers << ->(job, ex) do
      Rails.logger.warn("Job #{job['class']} with args #{job['args']} failed after retries: #{ex.message}")
    end

    config.client_middleware do |chain|
      chain.add SidekiqUniqueJobs::Middleware::Client
    end

    config.server_middleware do |chain|
      chain.add SidekiqUniqueJobs::Middleware::Server
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

    config.client_middleware do |chain|
      chain.add SidekiqUniqueJobs::Middleware::Client
    end
  end

  puts "[Sidekiq Init] Initializer loaded!"

rescue => e
  puts "[Sidekiq Init] Failed to configure Sidekiq: #{e.message}"
end
