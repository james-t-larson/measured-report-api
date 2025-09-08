# This class is part of the MVP validation pipeline.
# It is meant to be called manually via `rails c` when working with content
# generated through the Gemini web UI. This will be automated in later stages.
# For now, it aggregates and runs all content validators

module Validations
  class Content
    class ValidationError < StandardError; end

    VALIDATORS = [
      Validators::WordCount,
      Validators::Readability,
      Validators::Sentiment
    ].freeze

    def self.validate!(markdown)
      failed = false
      results = VALIDATORS.map do |validator|
        begin
          result = validator.new(markdown).validate!
          "Validation Passed, #{validator.name.demodulize}: #{result}"
        rescue StandardError => e
          failed = true
          "Validation Failed: #{e.message}"
        end
      end

      puts results

      failed
    end
  end
end
