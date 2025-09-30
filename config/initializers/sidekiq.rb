require "sidekiq"
require "sidekiq-scheduler"
require "sidekiq-status"
require "sidekiq-unique-jobs"

begin
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
    config.on(:startup) do
      schedule_file = "config/sidekiq_scheduler.yml"

      if File.exist?(schedule_file)
        Sidekiq::Scheduler.dynamic = true
        Sidekiq.schedule = YAML.load_file(schedule_file)
        Sidekiq::Scheduler.reload_schedule!
      end
    end

    config.death_handlers << ->(job, ex) do
      Rails.logger.warn("Job #{job['class']} with args #{job['args']} failed after retries: #{ex.message}")
    end

    config.server_middleware do |chain|
      chain.add SidekiqUniqueJobs::Middleware::Server
      chain.add Sidekiq::Status::ServerMiddleware
    end

    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware
      chain.add SidekiqUniqueJobs::Middleware::Client
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

    config.client_middleware do |chain|
      chain.add Sidekiq::Status::ClientMiddleware
      chain.add SidekiqUniqueJobs::Middleware::Client
    end
  end

rescue => e
  puts "[Sidekiq Init] Failed to configure Sidekiq: #{e.message}"
end
