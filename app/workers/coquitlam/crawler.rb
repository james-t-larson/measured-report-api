module Coquitlam
  class Crawler
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform(feeds = nil)
      feeds ||= Coquitlam::Feeds.retrieve.map(&:id)

      return if feeds.empty?

      feed_id = feeds.shift
      feed = Feed.find_by(id: feed_id)

      if feed
        entries = Rss::Client.fetch(url: feed.url)
        entries.each do |entry|
          Rss::Import.new(entry, feed)
        end
      else
        Rails.logger.warn "[Coquitlam::Crawler] Feed with ID #{feed_id} not found"
      end

      Coquitlam::Crawler.new.perform(feeds) unless feeds.empty?
    rescue => e
      Rails.logger.error "[Coquitlam::Crawler] Failed: #{e.message}"
    end
  end
end
