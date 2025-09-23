class FeedEntry < ApplicationRecord
  belongs_to :feed
  belongs_to :category
  has_one :generated_article, class_name: "Article", foreign_key: "feed_entry_id"

  validates :feed_id, :category_id, :guid, presence: true
  validates :url, format: URI.regexp(%w[http https]), presence: true

  scope :most_recent, -> { order(published_at: :desc) }
end
