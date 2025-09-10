require "httparty"

module Reddit
  class Client
    DEFAULT_BASE = "https://www.reddit.com"
    OAUTH_BASE = "https://oauth.reddit.com"
    TOKEN_URL = "#{DEFAULT_BASE}/api/v1/access_token"
    MEDIA_ASSET_URL = "#{OAUTH_BASE}/api/media/asset.json"

    def initialize
      @user_agent = "agent:coquitlam-bot (by u/CoquitlamReport)"
      @client_id = "1D6VcYqVk0G6gc-szc34Ew"
      @client_secret = "fKNBcwEzYdYyrlNxzXKo7b5ESHND1Q"
      @username = "CoquitlamReport"
      @password = "gaksIw-basfyq-rorfy4"
      @access_token = authenticate
    end


    private

    def authenticate
      auth = { username: @client_id, password: @client_secret }

      response = HTTParty.post(
        TOKEN_URL,
        basic_auth: auth,
        headers: { "User-Agent" => @user_agent },
        body: {
          grant_type: "password",
          username: @username,
          password: @password,
          scope: "submit identity"
        }
      )

      if response.code == 200
        response.parsed_response["access_token"]
      else
        Rails.logger.error "[Reddit::Client] Auth failed: #{response.code} – #{response.body}"
        raise "Reddit auth failed: #{response.body}"
      end
    end

    def auth_headers
      {
        "Authorization" => "bearer #{@access_token}",
        "User-Agent" => @user_agent
      }
    end

    def post(url:, body:, **options)
      body = options[:s3_request] ? body : payload(**body)
      message = "[Reddit::Client] Post request: url=#{url}, body=#{body}"
      response = HTTParty.post(
        url,
        headers: auth_headers,
        body: body
      )

      if response.code.between?(200, 299)
        message = "[Reddit::Client] Post request SUCCESS: code=#{response.code}, url=#{url}, body=#{body}, response=#{response.body}, auth_headers=#{auth_headers}"
        Rails.logger.error(message)
        return response if options[:s3_request]

        response.parsed_response
      else
        message = "[Reddit::Client] Post request FAILED: code=#{response.code}, url=#{url}, body=#{body}, response=#{response.body}, auth_headers=#{auth_headers}"
        Rails.logger.error(message)
        raise message
      end
    end

    def get(url:)
      response = HTTParty.get(
        url,
        headers: auth_headers
      )

      if response.code.between?(200, 299)
        message = "[Reddit::Client] Get request SUCCESS: code=#{response.code}, url=#{url}, response=#{response.body}"
        Rails.logger.error(message)

        response.parsed_response
      else
        message = "[Reddit::Client] Get request FAILED: code=#{response.code}, url=#{url}, response=#{response.body}"
        Rails.logger.error(message)
        raise message
      end
    end

    def payload(subreddit:, title:, kind:, url: nil, body: nil, media_asset_id: nil, flair_id: nil, flair_text: nil, nsfw: false, spoiler: false, original_content: false, send_replies: true, ad: false, resubmit: nil)
      payload = {
        sr: subreddit,
        title: title,
        kind: kind,
        nsfw: nsfw.to_s,
        spoiler: spoiler.to_s,
        original_content: original_content.to_s,
        sendreplies: send_replies.to_s,
        api_type: "json"
      }

      payload[:resubmit] = resubmit if resubmit.present?
      payload[:text] = body if body.present?
      payload[:flair_id] = flair_id if flair_id.present?
      payload[:flair_text] = flair_text if flair_text.present?
      payload[:media_asset_id] = media_asset_id if media_asset_id.present?
      payload[:url] = url if url.present?
      payload
    end

    def upload_image(image_path:)
      mime = detect_mime_type(image_path)

      lease = post(
        url: MEDIA_ASSET_URL,
        body: { filepath: File.basename(image_path), mimetype: mime },
        s3_request: true
      )

      args  = lease.dig("args") || lease.dig("json", "args")
      asset = lease.dig("asset") || lease.dig("json", "asset")
      raise "Unexpected lease shape: #{lease.inspect}" unless args && asset

      asset_id = asset["asset_id"] || asset["id"] || asset["assetId"]
      raise "Missing asset_id in lease: #{asset.inspect}" unless asset_id

      Rails.logger.info "[Reddit::Client] Uploaded image asset #{asset_id} to S3"

      10.times do
        url = "#{OAUTH_BASE}/api/media/asset"
        resp = get(url: "#{url}/#{asset_id}")
        state = resp.dig("asset", "processing_state") || resp.dig("processing_state")
        Rails.logger.info "[Reddit::Client] resp=#{resp}"

        break if state != "incomplete"
        sleep(3 + rand) # 3s + jitter
      end

      asset_id
    end

    def download_tempfile(url)
      ext = File.extname(URI.parse(url).path)
      tmp = Tempfile.new([ "temp_file", ext ], binmode: true)

      URI.open(url, "rb") do |remote|
        IO.copy_stream(remote, tmp)
      end

      tmp.rewind
      tmp
    end

    def detect_mime_type(path)
      if defined?(Marcel)
        Marcel::MimeType.for(Pathname.new(path), name: File.basename(path)) || "application/octet-stream"
      else
        ext = File.extname(path).downcase
        case ext
        when ".jpg", ".jpeg" then "image/jpeg"
        when ".png"          then "image/png"
        when ".gif"          then "image/gif"
        when ".webp"         then "image/webp"
        else "application/octet-stream"
        end
      end
    end
  end
end
