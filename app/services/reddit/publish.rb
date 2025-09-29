module Reddit
  class Publish < Client
    SUBMIT_URL = "#{OAUTH_BASE}/api/submit"

    def image(source_url:)
      temp_file = download_tempfile(source_url)
      asset_id = upload_image(temp_file: temp_file)

      asset_id

      # post(
      #   url: SUBMIT_URL,
      #   body: {
      #     subreddit: subreddit,
      #     title: title,
      #     kind: "image",
      #     url: source_url,
      #     media_asset_id: asset_id
      #   }
      # )
    end

    def link(subreddit:, title:, url:)
      result = post(
        url: SUBMIT_URL,
        body: {
          subreddit: subreddit,
          kind: "link",
          resubmit: true,
          title: title,
          url: url
        }
      )

      key = Reddit::Keys.post_history(url: url)
      Rails.cache.write(key, true) if result.present?

      result
    end
  end
end
