class FetchFeedsJob < ApplicationJob
  queue_as :default

  def perform
    Feed.find_each do |feed|
      begin
        response = HTTParty.get(feed.url)
        parsed = Feedjira.parse(response.body)

        parsed.entries.each do |entry|
          feed.feed_entries.find_or_create_by(url: entry.url) do |e|
            e.title = entry.title
            e.published_at = entry.published || Time.current
            e.summary = entry.summary
          end
        end

      rescue => e
        Rails.logger.error("Failed to fetch feed: #{feed.url}, error: #{e.message}")
      end
    end
  end
end
