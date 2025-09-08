module Llm
  module Validators
    class Readability
      class ReadabilityError < StandardError; end

      ACCEPTABLE_SCORE_RANGE = (60..75)

      def self.call(content)
        grade = FleschKincaid.read(content).score

        unless (ACCEPTABLE_SCORE_RANGE).cover?(grade)
          raise ReadabilityError, "[Validators::Readability] Out-of-range score: #{grade}, Acceptable Range: #{ACCEPTABLE_SCORE_RANGE}"
        end

        grade
      end
    end
  end
end
