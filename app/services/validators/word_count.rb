module Validators
  class WordCount < Validator
    class WordCountError < StandardError; end

    ACCEPTABLE_WORD_COUNTS = (250..500).freeze

    def validate!
      word_count = @content.split(/\s+/).count

      unless (ACCEPTABLE_WORD_COUNTS).cover?(word_count)
        raise WordCountError, "[Validators::WordCount] Out-of-range score: #{word_count}, Acceptable Range: #{ACCEPTABLE_WORD_COUNTS}"
      end

      word_count
    end
  end
end
