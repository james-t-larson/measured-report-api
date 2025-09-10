# frozen_string_literal: true

module Reddit
  class Draft < Client
    DRAFTS_URL  = "#{OAUTH_BASE}/api/v1/drafts.json"

    def image(source_url:, **options)
      raise ArgumentError, "source_url" unless source_url

      temp_file = download_tempfile(source_url)
      asset_id = upload_image(image_path: temp_file)
      payload = payload(
        kind: "image",
        media_asset_id: asset_id,
        **options
      )

      put(
        url: DRAFTS_URL,
        payload: payload
      )
    end
  end
end
