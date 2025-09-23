
module Reddit
  class Client
    DEFAULT_BASE = "https://www.reddit.com"
    OAUTH_BASE = "https://oauth.reddit.com"
    TOKEN_URL = "#{DEFAULT_BASE}/api/v1/access_token"
    MEDIA_ASSET_URL = "#{OAUTH_BASE}/api/media/asset.json"
    USER_NAME = "CoquitlamReport"

    def initialize
      @user_agent = "agent:coquitlam-bot (by u/CoquitlamReport)"
      @client_id = "1D6VcYqVk0G6gc-szc34Ew"
      @client_secret = "fKNBcwEzYdYyrlNxzXKo7b5ESHND1Q"
      @username = USER_NAME
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
          scope: "submit identity read history"
        }
      )

      if response.code == 200
        response.parsed_response["access_token"]
      else
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
      if options[:file] && options[:file].is_a?(File)
        require "multipart_post"
        body["file"] = UploadIO.new(options[:file], body["Content-Type"] || "application/octet-stream")
      end

      response = HTTParty.post(
        url,
        headers: options[:file] ? {} : auth_headers,
        body: body,
        multipart: options[:file] || false
      )

      if response.code.between?(200, 299)
        return response if options[:s3_request]

        response.parsed_response
      else
        raise "[Reddit::Client] Post request FAILED: code=#{response.code}, url=#{url}, body=#{body}, response=#{response.body}, auth_headers=#{auth_headers}"
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

    def connect_ws(ws_url, asset_id)
      processed = false

      EM.run do
        ws = Faye::WebSocket::Client.new(ws_url)

        ws.on :open do |event|
          Rails.logger.info "[Reddit::Client] WebSocket connection opened to #{ws_url}"
        end

        ws.on :message do |event|
          Rails.logger.info "[Reddit::Client] WebSocket message: #{event.data.inspect}"

          begin
            data = JSON.parse(event.data)
          rescue JSON::ParserError => e
            Rails.logger.error "[Reddit::Client] WebSocket JSON parse error: #{e.message}"
            next
          end

          if data["asset_id"] == asset_id && data["processing_state"] == "succeeded"
            Rails.logger.info "[Reddit::Client] WebSocket asset succeeded: #{data.inspect}"
            processed = true
            ws.close
            EM.stop
          end
        end

        ws.on :error do |e|
          Rails.logger.error "[Reddit::Client] WebSocket error: #{e.message}"
          EM.stop
        end

        ws.on :close do |event|
          Rails.logger.info "[Reddit::Client] WebSocket closed: code=#{event.code}, reason=#{event.reason}"
          EM.stop unless processed
        end
      end

      raise "Image processing failed or timed out" unless processed

      processed
    end

    def upload_image(temp_file:, mimetype: nil)
      mimetype ||= detect_mime_type(temp_file)

      lease = post(
        url: MEDIA_ASSET_URL,
        body: { filepath: File.basename(temp_file), mimetype: mimetype },
        s3_request: true
      )

      fields = lease.dig("args", "fields")
      action = lease.dig("args", "action")
      asset = lease.dig("asset")
      asset_id, processed, ws_url = asset&.values_at("asset_id", "processing_state", "websocket_url")

      Rails.logger.info <<~LOG
        [Reddit::Client] Extracted values:
          - fields present? : #{fields.present?}
          - action present? : #{action.present?}
          - asset present?  : #{asset.present?}
          - asset_id present?  : #{asset_id.present?}
          - processed present?  : #{processed.present?}
          - ws_url present?  : #{ws_url.present?}
      LOG

      raise "Invalid asset response: #{lease.inspect}" if [ action, fields, asset_id, processed, ws_url ].any?(&:nil?)

      # action_url = action.start_with?("http") ? action : "https:#{action}"
      # action_body = fields.each_with_object({}) do |field, body|
      #   body[field["name"]] = field["value"]
      # end
      #
      # lease = post(
      #   url: action_url,
      #   body: action_body,
      #   s3_request: true,
      #   file: temp_file
      # )

      Rails.logger.info "[Reddit::Client] Uploaded image asset #{asset_id} to S3"

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
