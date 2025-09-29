module Reddit
  class History < Client
    def initialize(subreddit:)
      super()

      @url ||= "#{OAUTH_BASE}/r/#{subreddit}/search"
    end

    def link_posted_before?(url)
      key = Reddit::Keys.post_history(url: url)
      return true if Rails.cache.read(key)

      url = "url:#{url}"
      posts = get(url: @url, params: { q: url, type: :link, restrict_sr: 1 }).dig("data", "children")

      posted_already = !posts.empty?

      Rails.cache.write(key, posted_already)

      posted_already
    end
  end
end
