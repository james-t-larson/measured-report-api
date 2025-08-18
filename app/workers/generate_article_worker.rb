class GenerateArticleWorker
  include Sidekiq::Worker

  sidekiq_options(
    queue: :default,
    retry: 3,
    lock: :until_and_while_executing,
    lock_timeout: 0,
    on_conflict: { client: :log, server: :raise }
  )

  def self.sidekiq_unique_context(job)
    [ job["class"], job["queue"] ]
  end

  sidekiq_retries_exhausted do |msg, _ex|
    entry_id = msg["args"].first
    feed_entry = FeedEntry.find_by(id: entry_id)

    if feed_entry
      feed_entry.condemn!
    end

    GenerateArticleWorker.process_entries
  end

  def self.process_entries
    if FeedEntry.fresh_souls.exists?
      feed_entry = FeedEntry.fresh_souls.first
      feed_entry.ascend! if Article.exists?(feed_entry_id: feed_entry)

      GenerateArticleWorker.perform_async(feed_entry.id)
    else
      Rails.logger.info("[GenerateArticleWorker] Generation for last batch complete")
    end
  end

  def perform(entry_id)
    begin
      feed_entry = FeedEntry.find(entry_id)

      Rails.logger.info("[GenerateArticleWorker] Generating Article for Feed Entry #{feed_entry.id}: #{feed_entry.title}.")

      generator = ArticleGenerator.new
      generated = generator.generate_article(
        title: feed_entry.title,
        summary: feed_entry.summary,
        content: feed_entry.content,
      )[:article]

      feed_entry.present_to_the_fates!
      content = generated[:content]
      sentiment_score = SentimentAnalyzer.instance.score(content)
      unless Article::SENTIMENT_RANGE.cover?(sentiment_score)
        # TODO Properly track this in the database. create a column for tracking which categories need sentimentality check
        raise HighSentimentError, "Sentiment too high (#{sentiment_score})" if [ "politics", "world" ].include?(feed_entry.category.slug)
      end

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
      GenerateArticleWorker.process_entries
    rescue ArticleGenerator::MissingAPIKeyError => e
      Rails.logger.warn "[GenerateArticleWorker] Skipping article generation: #{e.message}"
      raise e
    rescue => e
      Rails.logger.error "[GenerateArticleWorker] Error: #{e.message}"
      raise e
    end
  end
end
