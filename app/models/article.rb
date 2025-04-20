class Article < ApplicationRecord
  SENTIMENT_RANGE = (-3.0..3.0).freeze

  belongs_to :category
  belongs_to :feed_entry

  validates :title, presence: true, length: { maximum: 255 }
  validates :summary, length: { maximum: 500 }, allow_blank: true
  validates :content, presence: true
  validates :sources, length: { maximum: 255 }, allow_blank: true
  validates :image, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :sentiment_score, numericality: {
    greater_than_or_equal_to: SENTIMENT_RANGE.begin,
    less_than_or_equal_to: SENTIMENT_RANGE.end
  }, allow_blank: true

  scope :positive_sentiment, -> { where("sentiment_score > ?", 0) }
end
