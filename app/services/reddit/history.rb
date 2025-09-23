module Reddit
  class History < Client
    HISTORY_URL = "https://oauth.reddit.com/user/#{USER_NAME}/submitted?limit=100"

    def last_post_time
      posts = get(url: HISTORY_URL).dig("data", "children") || []

      latest = posts.max_by { |p| p.dig("data", "created").to_i }

      latest.dig("data", "created")
    end
  end
end
