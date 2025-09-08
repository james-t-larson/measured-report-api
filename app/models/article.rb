class Article < ApplicationRecord
  PIPELINE_STATES = {
    failed: -1,
    needs_sanitization: 0,
    needs_word_count: 1,
    needs_sentiment: 2,
    needs_readability: 3,
    needs_references: 4,
    needs_disclaimer: 8,
    needs_attributions: 6,
    complete: 7
  }.freeze

  enum pipeline: PIPELINE_STATES

  belongs_to :category

  validates :sentiment, numericality: true, allow_blank: true
  validates :title, length: { maximum: 255 }, allow_blank: true
  validates :summary, length: { maximum: 500 }, allow_blank: true
  validates :content, presence: true
  validates :sources, length: { maximum: 255 }, allow_blank: true
  validates :image, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true

  scope :positive_sentiment, -> { where("sentiment_score > ?", 0) }
end
