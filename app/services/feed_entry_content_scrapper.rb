require "httparty"
require "nokogiri"

class FeedEntryContentScrapper
  def initialize(url, selector)
    @url = url
    @selector = selector
  end

  def call
    # NOTE: Might need to move working request into the DB as json to ensure that all requests go through
    response = HTTParty.get(
      @url,
      headers: {
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:137.0) Gecko/20100101 Firefox/137.0",
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language" => "en-CA,en-US;q=0.7,en;q=0.3",
        "Accept-Encoding" => "gzip, deflate, br, zstd",
        "Connection" => "keep-alive",
        "Upgrade-Insecure-Requests" => "1",
        "Sec-Fetch-Dest" => "document",
        "Sec-Fetch-Mode" => "navigate",
        "Sec-Fetch-Site" => "none",
        "Sec-Fetch-User" => "?1",
        "Priority" => "u=0, i",
        "Pragma" => "no-cache",
        "Cache-Control" => "no-cache"
      },
      timeout: 10
    )

    # TODO: Add image extraction
    if response.success?
      document = Nokogiri::HTML(response.body)
      elements = document.css("#{@selector}")

      elements.map(&:text).map(&:strip)
    else
      puts "Failed to fetch URL: HTTP #{response.code}"
      []
    end
  rescue StandardError => e
    puts "Something went wrong: #{e.message}"
    []
  end
end
