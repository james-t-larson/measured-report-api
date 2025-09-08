module Llm
  class Orchestrator
    include Sidekiq::Worker
    sidekiq_options queue: :default, retry: false

    # NOTE: Since the end product will be getting the content from an api
    # I will be creating an article manually from the article that I select
    # as a good candidate.
    #
    # NOTE: The manual flow will be
    # - Generate article manually
    # - Create Article from rails c
    # - Start sidekiq
    # - Pass Article.id into .perform
    # - Repeat if validations, or another failure happens


    STATE_PROCESSORS = {
      needs_sanitization: ->(article) {
        Rails.logger.info("[Llm::Orchestrator] Sanitizing article: #{article.to_json}")
        content = Llm::Preprocessors::Sanitize.new(article.content).sanitized
        article.update!(content: content)
        article.needs_word_count!
      },
      needs_word_count: ->(article) {
        Rails.logger.info("[Llm::Orchestrator] Validating word count article: #{article.to_json}")
        word_count = Llm::Validators::WordCount.call(article.content)
        article.update!(word_count: word_count)
        article.needs_sentiment!
      },
      needs_sentiment: ->(article) {
        Rails.logger.info("[Llm::Orchestrator] Validating sentiment: #{article.to_json}")
        score = Llm::Validators::Sentiment.call(article.content)
        article.update!(sentiment: score)
        article.needs_readability!
      },
      needs_readability: ->(article, meeting) {
        Rails.logger.info("[Llm::Orchestrator] Validating readibility: #{article.to_json}")
        score = Llm::Validators::Readability.call(article.content)
        article.update!(readability: score)
        article.needs_references!
      },
      needs_references: ->(article, meeting) {
        content = Llm::Postprocessors::References.new(meeting, article.content).completed
        article.update!(content: content)
        article.needs_disclaimer!
      },
      needs_disclaimer: ->(article) {
        content = Llm::Postprocessors::Disclaimer.new(article.content).completed
        article.update!(content: content)
        article.needs_attributions!
      },
      needs_attributions: ->(article) {
        # placeholder for future manual or API step
        article.complete!
      }
    }.freeze

    def perform(article_id, meeting_id)
      meeting = Meeting.find(meeting_id)
      article = Article.find(article_id)
      article.reload

      current_state = article.pipeline.to_sym
      Rails.logger.info("[Llm::Orchestrator] Current State: #{article.to_json}")

      if STATE_PROCESSORS[current_state].arity == 1
        STATE_PROCESSORS[current_state].call(article)
      else
        STATE_PROCESSORS[current_state].call(article, meeting)
      end

      next_state = article.reload.pipeline.to_sym
      if STATE_PROCESSORS.key?(next_state)
        self.class.perform_async(article.id, meeting.id)
      end
    end
  end
end
