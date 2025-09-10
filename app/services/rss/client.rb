module Rss
  class Client
    def self.fetch(url:)
      response = HTTParty.get(url, headers: { "Accept" => "application/rss+xml" })

      Rails.logger.debug "[Rss::Client] HTTP response status: #{response.code}"

      if response.success?
        Feedjira.parse(response.body).entries
      else
        Rails.logger.warn "[Rss::Client] Failed to fetch RSS feed from #{url}"
        []
      end
    rescue StandardError => e
      Rails.logger.error "[Rss::Client] Error fetching RSS feed: #{e.message}"
      []
    end
  end
end
