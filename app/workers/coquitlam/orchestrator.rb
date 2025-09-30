module Coquitlam
  class Orchestrator
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    sidekiq_options queue: :default, retry: 3

    SUBREDDIT = "coquitlamreport"

    def posted_already?(link)
      Reddit::History.new(subreddit: SUBREDDIT).link_posted_before?(link)
    end

    def posted_today_key
      "coquitlam:orchestrator:posted:#{Date.today}"
    end

    def record_worker_posted
      Rails.cache.write(posted_today_key, true, expires_in: 23.hours)
    end

    def worker_posted_today?
      Rails.cache.read(posted_today_key)
    end

    def perform
      store started_at: Time.current.to_s

      if worker_posted_today?
        msg = "[Coquitlam::Orhestrator] Skipping, already posted today"
        store message: msg
        Rails.logger.info(msg)
        store stopped_at: Time.current.to_s
        return
      end

      store crawler_started: Time.zone.now.to_s
      Coquitlam::Crawler.new.perform
      store crawler_completed: Time.zone.now.to_s

      entries = FeedEntry.published_today

      store entries_published_today: entries.pluck(:title, :url).to_json
      Rails.logger.info("[Orchestrator] Found #{entries.size} entries")

      posted_this_run = false
      entries.each do |entry|
        Rails.logger.info("[Orchestrator] Processing entry: #{entry.title} (#{entry.url})")

        if posted_already?(entry.url)
          Rails.logger.info("[Orchestrator] Already posted: #{entry.url}")
          store "posted_already_#{entry.id}" => entry.url
          posted_this_run = true
          next
        else
          Rails.logger.info("[Orchestrator] Posting to Reddit: #{entry.url}")
          Reddit::Publish.new.link(subreddit: SUBREDDIT, title: entry.title, url: entry.url)
          record_worker_posted

          store posted_url: entry.url, posted_title: entry.title
          Rails.logger.info("[Orchestrator] Posted successfully, exiting loop")
          break
        end
      end

      unless posted_this_run
        store message: "No new entries to post."
        Rails.logger.info("[Orchestrator] No new entries to post.")
      end

      store completed_at: Time.current.to_s
      Rails.logger.info("[Orchestrator] Done")
    rescue => e
      store error: e.message, backtrace: e.backtrace.take(5).join("\n")
      raise e
    end
  end
end
