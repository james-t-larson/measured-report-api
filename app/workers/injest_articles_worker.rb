# TODO, rename to InjestEntriesWorker, move to jobs
class InjestArticlesWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  REDIS_FEED_CURSOR_KEY = "injest_articles_worker:current_feed"

  def perform
    feed = current_feed
    Rails.logger.info "[InjestArticlesWorker] Fetching feed from #{feed.url}"

    response = HTTParty.get(feed.url)
    entries = Feedjira.parse(response.body).entries

    new_articles_count = 0

    entries.each do |entry|
      cache_key = "feed_entry:#{entry.entry_id}"

      next if Rails.cache.exist?(cache_key)

      content = entry.content
      if entry.url.present? && feed.content_class.present?
        Rails.logger.info "[InjestArticlesWorker] Scraping content for: #{entry.url}"
        content_chunks = FeedEntryContentScrapper.new(entry.url, feed.content_class).call
        content = content_chunks.join("\n") if content_chunks.present?
      end

      next if content.blank?
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
        new_articles_count += 1
        internal_entry.assign_attributes(processed_entry)
        internal_entry.save!
      end

      Rails.cache.write(cache_key, true, expires_in: 24.hours)
    end

    if new_articles_count == 0
      Rails.logger.info "[InjestArticlesWorker] No new articles were found."
    else
      Rails.logger.info "[InjestArticlesWorker] Enqueuing GenerateArticleWorker to run after ingestion."
      GenerateArticleWorker.perform_async
    end
  rescue => e
    Rails.logger.error "[InjestArticlesWorker] Failed: #{e.message}"
  end

    private

  def current_feed
    last_id = Rails.cache.read(REDIS_FEED_CURSOR_KEY).to_i
    current_feed = Feed.where("id > ?", last_id).first || Feed.first

    Rails.cache.write(REDIS_FEED_CURSOR_KEY, current_feed.id)
    current_feed
  end
end
