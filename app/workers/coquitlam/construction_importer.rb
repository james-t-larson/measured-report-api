module Coquitlam
  class ConstructionImporter
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform
      feed = Coquitlam::Feed.retrieve
      entries = Rss::Client.fetch(url: feed.url)

      entries.each do |entry|
        Rss::Import.new(entry, feed)
      end
    rescue => e
      Rails.logger.error "[Coquitlam::ConstructionEvents] Failed: #{e.message}"
    end
  end
end
