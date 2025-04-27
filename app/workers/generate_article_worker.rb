class GenerateArticleWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 3, dead: false

  class HighSentimentError < StandardError; end

  def perform
    lock_key = "generated_article_worker_locked"

    article_generation_locked = Rails.cache.exist?(lock_key)
    return if article_generation_locked

    @error = false

    begin
      Rails.cache.write(lock_key, true, expires_in: 24.hours)
      feed_entry = FeedEntry.fresh_souls.first

      return Rails.logger.info("[GenerateArticleWorker] No articles to generate.") if feed_entry.nil?
      return Rails.logger.info("[GenerateArticleWorker] Skipping, Article Generated for Entry #{feed_entry.id}: #{feed_entry.title}.") if Article.exists?(feed_entry_id: feed_entry.id)

      Rails.logger.info("[GenerateArticleWorker] Generating Article for Feed Entry #{feed_entry.id}: #{feed_entry.title}.")

      generator = ArticleGenerator.new
      generated = generator.generate_article(
        title: feed_entry.title,
        summary: feed_entry.summary,
        content: feed_entry.content,
      )[:article]

      feed_entry.present_to_the_fates!
      Rails.logger.info("[GenerateArticleWorker] Generated Article for Feed Entry #{feed_entry.id}: #{generated}.")
      content = generated[:content]
      sentiment_score = SentimentAnalyzer.instance.score(content)
      unless Article::SENTIMENT_RANGE.cover?(sentiment_score)
        feed_entry.send_to_the_river_stix!
        raise HighSentimentError, "Sentiment too high (#{sentiment_score})"
      end

      # TODO: Send to purgatory when retries failed for review.

      Article.create!(
        feed_entry: feed_entry,
        title: generated[:title],
        summary: generated[:summary],
        content: content,
        sources: feed_entry.url,
        category: feed_entry.category,
        image: feed_entry.image,
        sentiment_score: sentiment_score,
      )

      feed_entry.ascend!
      Rails.logger.info "[GenerateArticleWorker] Generated Article for Feed Entry #{feed_entry.id}: #{feed_entry.title} Complete"
    rescue HighSentimentError => e
      @error = true
      raise e
    rescue ArticleGenerator::MissingAPIKeyError => e
      Rails.logger.warn "[GenerateArticleWorker] Skipping article generation: #{e.message}"
      @error = true
      raise e
    rescue => e
      Rails.logger.error "[GenerateArticleWorker] Error: #{e.message}"
      @error = true
      raise e
    ensure
      Rails.cache.delete(lock_key)
      if FeedEntry.fresh_souls.exists? && !@error
        GenerateArticleWorker.perform_async
      else
       Rails.logger.info "[GenerateArticleWorker] Generation for last batch of articles complete"
      end
    end
  end
end
