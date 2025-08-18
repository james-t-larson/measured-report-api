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
      errors = VALIDATORS.each_with_object([]) do |validator, errs|
        begin
          validator.new(markdown).validate!
        rescue StandardError => e
          errs << e.message
        end
      end

      raise ValidationError, errors.join("; ") unless errors.empty?

      true
    end
  end
end
