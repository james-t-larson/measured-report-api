class SentimentAnalyzer
  def self.instance
    @instance ||= begin
      analyzer = Sentimental.new
      analyzer.load_defaults
      analyzer
    end
  end
end
