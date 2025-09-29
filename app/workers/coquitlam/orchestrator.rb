module Coquitlam
  class Orchestrator
    include Sidekiq::Worker

    sidekiq_options(
      queue: :default,
      retry: 3,
    )

    SUBREDDIT = "coquitlamreport"

    def posted_already?(link)
      Reddit::History.new(subreddit: SUBREDDIT).link_posted_before?(link)
    end

    def key
      "coquitlam:orchestrator:posted:#{Date.today}"
    end

    def record_worker_posted
      Rails.cache.write(key, true, expires_in: 23.hours)
    end

    def worker_posted_today?
      Rails.cache.read(key)
    end

    def perform
      if worker_posted_today?
        Rails.logger.info("[Coquitlam::Orhestrator] Skipping job execution, posted today already")
        return
      else
        Rails.logger.info("[Coquitlam::Orhestrator] Starting Coquitlam::Crawler.perform")
      end

      Coquitlam::Crawler.new.perform
      Rails.logger.info("[Coquitlam::Orhestrator] Finished crawler perform, fetching entries")

      entries = FeedEntry.published_today
      Rails.logger.info("[Coquitlam::Orhestrator] Found #{entries.size} entries")

      entries.each do |entry|
        Rails.logger.info("[Coquitlam::Orhestrator] Processing entry: #{entry.title} (#{entry.url})")

        if posted_already?(entry.url)
          Rails.logger.info("[Coquitlam::Orhestrator] Skipping already-posted entry: #{entry.url}")
          next
        else
          Rails.logger.info("[Coquitlam::Orhestrator] Posting new link to Reddit: #{entry.url}")
          Reddit::Publish.new.link(subreddit: SUBREDDIT, title: entry.title, url: entry.url)
          record_worker_posted
          Rails.logger.info("[Coquitlam::Orhestrator] Successfully posted entry, stopping loop")
          break
        end
      end

      Rails.logger.info("[Coquitlam::Orhestrator] Done processing entries")
    end
  end
end
