module Validators
  class Readability < Validator
    class ReadabilityError < StandardError; end

    ACCEPTABLE_SCORE_RANGE = (65..75)

    def validate!
      grade = FleschKincaid.read(@content).score

      unless (ACCEPTABLE_SCORE_RANGE).cover?(grade)
        raise ReadabilityError, "[Validators::Readability] Out-of-range score: #{grade}, Acceptable Range: #{ACCEPTABLE_WORD_COUNTS}"
      end

      grade
    end
  end
end
