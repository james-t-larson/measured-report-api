module Validators
  class Sentiment < Validator
    class HighSentimentError < StandardError; end

    ACCEPTABLE_SENTIMENT_RANGE = (-3.0..3.0).freeze

    def instance
      @instance ||= begin
        analyzer = Sentimental.new
        analyzer.load_defaults
        analyzer
      end
    end

    def validate!
      score = instance.score(@content)

      unless ACCEPTABLE_SENTIMENT_RANGE.cover?(score)
        raise HighSentimentError, "[Validators::Sentiment] Out-of-range score: #{score}, Acceptable Range: #{ACCEPTABLE_SENTIMENT_RANGE}"
      end

      score
    end
  end
end
