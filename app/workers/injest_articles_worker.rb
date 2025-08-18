# TODO: Change to news outlet theme
# - Potential pipeline
#   - Journalist Collects Story Ideas/Leads (Workers)
#   - Editor determines timeliness, novelty, and relevance
#     - Will require social media scrapping, based on entities mentioned
#     - This is where we do find the social score of the article
#     - There is a chance that the article will be published before peolple are talking about it
#     - To mitigate this, I can either slow down the rate of publication, or start a perioodic job
#   - Journalist creates a pitch (Pulls out entities), and relates them to the story
#   - Editor checks if story has not aleady been writen (Deduplication)
#     - Plagerism checkers and entity similarity might help here
#   - Reporter Writes arficles (LLM Generates Content)
#   - Article is sent to Standard Editors Team
#     - Fact Check Ombudsmen performs the same steps as above
#     - Word count Ombudsmen ensures length is correct
#     - Sentiment Ombudsmen approves or rejects (Sentiment Analysis), potnetially sends back to Journalist
#     - Grade Level Ombudsmen ensures it's below 8th grade (Flesch Kinkaid Grade Level)
#   - Article is sent to Legal Department for complaiance and risk assesment
#     - Plagerism Ombudsmen checks original content against Journalist's article, approves/rejects
#   - Once all checks have passed, the story is sent to the Editor-in-Chief (Me) for review
#     - Once approved, the article is published
#   - After this step, articles are marketed and corrections are published (daily review for corrections worker is needed)

class InjestArticlesWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  REDIS_FEED_CURSOR_KEY = "injest_articles_worker:current_feed"

  def perform
    feed = next_feed
    Rails.logger.info "[InjestArticlesWorker] Fetching feed from #{feed.url}"

    response = HTTParty.get(feed.url, headers: { "Accept" => "application/rss+xml" })
    Rails.logger.debug "[InjestArticlesWorker] HTTP response status: #{response.code}"

    entries = Feedjira.parse(response.body).entries

    entries.each do |entry|
      cache_key = "feed_entry:#{feed.name}:#{entry.entry_id}"

      next if Rails.cache.exist?(cache_key)
      Rails.logger.debug "[InjestArticlesWorker] Processing entry: #{entry.title}"

      content = entry.content
      if entry.url.present? && feed.content_selector.present?
        Rails.logger.info "[InjestArticlesWorker] Scraping content for: #{entry.url}"
        content_chunks = FeedEntryContentScrapper.new(entry.url, feed.content_selector).call
        if content_chunks.present?
          content = content_chunks.join("\n")
        else
          Rails.logger.warn "[InjestArticlesWorker] Scraping returned no content for URL: #{entry.url}"
          Rails.cache.write(cache_key, true, expires_in: 24.hours)
        end
      end

      if content.blank?
        Rails.logger.warn "[InjestArticlesWorker] Skipping entry due to blank content, Entry: #{entry.url} #{entry.title}"
        # NOTE: Some RSS feeds return links to videos, so not all will be used. Might create adapter for transscripts if they exist
        # NOTE: Might create a feed entry and send directly to underworld for proper reporting on which ones fail
        # TODO: Create an alert that send all skiped entries to track errors. Might be able to use rails-admin instead
        Rails.cache.write(cache_key, true, expires_in: 24.hours)
        next
      end

      processed_entry = {
        title:        entry.title,
        url:          entry.url,
        summary:      entry.summary,
        content:      content,
        image:        entry.image,
        published_at: entry.published,
        sentiment_score: SentimentAnalyzer.instance.score(content)
      }

      internal_entry = FeedEntry.find_or_initialize_by(feed_id: feed.id, category_id: feed.category_id, guid: entry.entry_id)
      if internal_entry.new_record?
        internal_entry.assign_attributes(processed_entry)
        internal_entry.save!
      end

      Rails.cache.write(cache_key, true, expires_in: 24.hours)
    end

    GenerateArticleWorker.process_entries
  rescue => e
    Rails.logger.error "[InjestArticlesWorker] Failed: #{e.message}"
  end

  private

  def next_feed
    @previous_feed = Feed.find_by(name: Rails.cache.read(REDIS_FEED_CURSOR_KEY)) || Feed.last
    @next_feed = Feed.find_by(id: @previous_feed.id + 1) || Feed.first

    Rails.cache.write(REDIS_FEED_CURSOR_KEY, @next_feed.name)
    @next_feed
  end

  def current_feed(increase_count = false)
    Feed.find_by(name: Rails.cache.read(REDIS_FEED_CURSOR_KEY))
  end
end
