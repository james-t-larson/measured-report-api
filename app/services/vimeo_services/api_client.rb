require "httparty"
require "json"

module VimeoServices
  module ApiClient
    CLIENT_BASE_URI = "https://vimeo.com"
    API_BASE_URI = "https://api.vimeo.com"

    BASE_HEADERS = {
      "Accept" => "*/*",
      "Accept-Language" => "en-US,en;q=0.9",
      "Authorization" => "",
      "Connection" => "keep-alive",
      "Referer" => CLIENT_BASE_URI,
      "Sec-Fetch-Dest" => "empty",
      "Sec-Fetch-Mode" => "cors",
      "Sec-Fetch-Site" => "same-origin",
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36",
      "X-Requested-With" => "XMLHttpRequest"
    }.freeze

    def self.fetch_vtt(url)
      fetch(url, json: false)
    end

    def self.fetch_texttracks(video_id)
      fetch("/videos/#{video_id}/texttracks")
    end

    def self.fetch_video(id)
      fetch("/videos/#{id}")
    end

    def self.fetch(path, method: :get, query: nil, body: nil, headers: {}, json: true)
      sess = session_headers or raise "no session"
      url  = path.start_with?("http://", "https://") ? path : "#{API_BASE_URI}#{path}"

      opts = {
        headers: sess.merge(headers),
        timeout: 15
      }
      opts[:query] = query if query
      opts[:body]  = body.to_json if body
      opts[:headers]["Content-Type"] ||= "application/json" if body

      resp = HTTParty.send(method, url, opts)

      raise "HTTP #{resp.code}: #{resp.body&.slice(0, 500)}" unless resp.success?

      if json
        JSON.parse(resp.body)
      else
        resp.body
      end
    rescue => e
      Rails.logger.error("VimeoServices::ApiClient.fetch failed: #{e.message}")
      nil
    end

    def self.session_headers
      resp  = HTTParty.get("#{CLIENT_BASE_URI}/_next/jwt", headers: BASE_HEADERS)
      token = JSON.parse(resp.body).fetch("token")

      raw = resp.headers["set-cookie"]
      set_cookies = raw.is_a?(Array) ? raw : [ raw ].compact
      pairs = set_cookies.flat_map { |h| h.split(/,(?=[^;]+?=)/) }
      cookie_header = pairs.map { |p| p.split(";").first }
                          .join("; ")

      BASE_HEADERS.merge(
        "Authorization" => "jwt #{token}",
        "Cookie" => cookie_header
      )
    rescue => e
      Rails.logger.error("VimeoServices::ApiClient.session_headers failed: #{e.message}")
      nil
    end
  end
end
