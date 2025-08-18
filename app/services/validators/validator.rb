module Validators
  class Validator
    class NotImplementedError < StandardError; end

    def initialize(markdown)
      @content = Preprocessors::Sanitize.new(markdown).sanitized
    end

    def validate!
      raise NotImplementedError, "#{self.class.name} must implement #validate!"
    end
  end
end
