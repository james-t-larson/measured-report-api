module Reddit
  class Publish < Client
    SUBMIT_URL = "#{OAUTH_BASE}/api/submit"

    def image(subreddit:, title:, source_url:)
      temp_file = download_tempfile(source_url)
      asset_id = upload_image(image_path: temp_file)

      post(
        url: SUBMIT_URL,
        body: {
          subreddit: subreddit,
          title: title,
          kind: "image",
          url: source_url,
          media_asset_id: asset_id
        }
      )
    end

    def link(subreddit:, title:, url:)
      post(
        url: SUBMIT_URL,
        body: {
          subreddit: subreddit,
          kind: "link",
          resubmit: true,
          title: title,
          url: url
        }
      )
    end
  end
end
