module PreProcessors
  class Sanitize
    attr_reader :sanitized

    def initialize(markdown)
      @sanitized = markdown
        .lines
        .filter_map { |line| clean_line(line) unless skip_line?(line) }
        .join
        .gsub(/\s+/, " ")
        .strip
    end

    private

    def clean_line(line)
      line
        .gsub(/\[cite_start\]/i, " ")
        .gsub(/\[cite[^\]]*\]/i, "")
        .gsub("* ", "")
    end

    def skip_line?(line)
      blank?(line) ||
        header?(line) ||
        italicized?(line) ||
        bolded?(line) ||
        horizontal_rule?(line)
    end

    def blank?(line)
      line.strip.empty?
    end

    def header?(line)
      line.match?(/^#+\s/)
    end

    def bolded?(line)
      line.match?(/^\*\*[^*]+\*\*$/)
    end

    def italicized?(line)
      line.match?(/^\*[^*]+\*$/)
    end

    def horizontal_rule?(line)
      line.strip.match?(/^[-*]{3,}\s*$/)
    end
  end
end
