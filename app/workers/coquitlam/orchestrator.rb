module Coquitlam
  class Orchestrator
    include Sidekiq::Worker

    sidekiq_options(
      queue: :default,
      retry: 3,
      lock: :until_and_while_executing,
      lock_timeout: 0,
      on_conflict: { client: :log, server: :raise }
    )

    def self.sidekiq_unique_context(job)
      [ job["class"], job["queue"] ]
    end

    sidekiq_retries_exhausted do |msg, _ex|
      Rails.logger.info "[Coquitlam::Orchestrator] Failed 3x: #{msg}"
    end

    START_HOUR   = 17  # 5 PM
    END_HOUR     = 24  # Midnight
    JITTER_RANGE = 25..35
    LOCK_KEY     = "coquitlam:reddit:post:lock"
    LOCK_TTL     = 36.hours
    SUB_REDDIT   = "/r/coquitlamreport"

    def perform
      now = Time.current
      Rails.logger.info "[Coquitlam::Orchestrator] Started at #{now}"

      start_time = now.change(hour: START_HOUR, min: 0, sec: 0) + 1.day
      next_time = now + rand(JITTER_RANGE).minutes
      Rails.logger.info "[Coquitlam::Orchestrator] Jittered delay: #{next_time.inspect}"

      if now.hour < START_HOUR || now.hour >= END_HOUR
        Rails.logger.info "[Coquitlam::Orchestrator] Outside window, scheduling for #{start_time}"
        self.class.perform_at(start_time)
        return
      end

      Rails.logger.info "[Coquitlam::Orchestrator] Running crawler"
      Coquitlam::Crawler.new.perform

      Rails.logger.info "[Coquitlam::Orchestrator] Attempting to acquire lock"
      got_lock = Rails.cache.write(
        LOCK_KEY,
        true,
        expires_in: LOCK_TTL,
        unless_exist: true
      )
      Rails.logger.info "[Coquitlam::Orchestrator] Lock acquired? #{got_lock}"

      newest_entry = FeedEntry.last
      Rails.logger.info "[Coquitlam::Orchestrator] Newest entry: #{newest_entry&.id} at #{newest_entry&.created_at}"

      new_entry = newest_entry.created_at > now
      Rails.logger.info "[Coquitlam::Orchestrator] Is entry new? #{new_entry}"

      if new_entry && got_lock
        title = newest_entry.title
        link = newest_entry.url
        Rails.logger.info "[Coquitlam::Orchestrator] Publishing to #{SUB_REDDIT}: #{title} (#{link})"
        # check if there have been any reddit posts in the last 36 hours
        # if lock was got, but there is already a post, return
        Reddit::Publish.new.link(subreddit: SUB_REDDIT, url: link, title: title)
        self.class.perform_at(start_time)
        return
      else
        Rails.logger.info "[Coquitlam::Orchestrator] Skipping publish (new_entry=#{new_entry}, got_lock=#{got_lock})"
      end

      Rails.logger.info "[Coquitlam::Orchestrator] Scheduling next run in #{next_time.inspect}"
      self.class.perform_at(next_time)
    end
  end
end
