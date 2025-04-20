class GenerateArticleWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 3

  MAX_SENTIMENT_SCORE = Article::SENTIMENT_RANGE.end
  MIN_SENTIMENT_SCORE = Article::SENTIMENT_RANGE.begin

  class HighSentimentError < StandardError; end

  def perform
    lock_key = "generated_article_worker_locked"

    article_generation_locked = Rails.cache.exist?(lock_key)
    return if article_generation_locked

    begin
      Rails.cache.write(lock_key, true, expires_in: 24.hours)
      feed_entry = FeedEntry.fresh_souls.first

      return Rails.logger.info("[GenerateArticleWorker] No articles to generate.") if feed_entry.nil?
      return Rails.logger.info("[GenerateArticleWorker] Skipping, Article Generated for Entry #{feed_entry.id}: #{feed_entry.title}.") if Article.exists?(feed_entry_id: feed_entry.id)

      feed_entry.present_to_the_fates!
      Rails.logger.info("[GenerateArticleWorker] Generating Article for Feed Entry #{feed_entry.id}: #{feed_entry.title}.")

      sleep(rand(10..20))

      content = Faker::Lorem.paragraphs(number: 3).join("\n\n")
      sentiment_score = SentimentAnalyzer.instance.score(content)
      if sentiment_score > Article::SENTIMENT_RANGE.end
        raise HighSentimentError, "Sentiment too high (#{sentiment_score})"
      end

      Article.create!(
        feed_entry: feed_entry,
        title: Faker::Lorem.sentence(word_count: 5),
        summary: Faker::Lorem.paragraph(sentence_count: 2),
        content: content,
        sources: Faker::Internet.url,
        category: feed_entry.category,
        image: Faker::LoremFlickr.image,
        sentiment_score: sentiment_score,
      )

      feed_entry.ascend!
      Rails.logger.info "[GenerateArticleWorker] Generated Article for Feed Entry #{feed_entry.id}: #{feed_entry.title} Complete"
    rescue => e
      Rails.logger.error "[GenerateArticleWorker] Error: #{e.message}"
      raise e
    ensure
      Rails.cache.delete(lock_key)
      if FeedEntry.fresh_souls.exists?
        GenerateArticleWorker.perform_async
      else
       Rails.logger.info "[GenerateArticleWorker] Generation for last batch of articles complete"
      end
    end
  end
end
