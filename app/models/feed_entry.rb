class FeedEntry < ApplicationRecord
  enum generation_edict: { has_fallen: -1, is_unjudged: 0, under_judgment: 1, in_purgatory: 2, has_ascended: 3 }, _prefix: :soul

  belongs_to :feed
  belongs_to :category
  has_one :generated_article, class_name: "Article", foreign_key: "feed_entry_id"

  validates :feed_id, :content, :category_id, :guid, presence: true
  validates :url, format: URI.regexp(%w[http https]), presence: true
  validates :sentiment_score, numericality: true, presence: true

  scope :created_today, -> { where(created_at: Time.now.beginning_of_day..Time.now.end_of_day) }
  scope :fresh_souls, -> { where(generation_edict: :is_unjudged) }
  scope :forsaken_souls, -> {
    where(generation_edict: :under_judgment)
      .where("updated_at <= ?", 1.day.ago)
  }
  scope :condemned_souls, -> {
    where(generation_edict: :in_purgatory)
      .where("updated_at <= ?", 1.day.ago)
  }
  scope :irredeemable_souls, -> {
    where(generation_edict: :has_fallen)
      .where("updated_at <= ?", 1.day.ago)
  }

  def present_to_the_fates!
    soul_under_judgment!
  end

  def send_to_the_underworld!
    soul_has_fallen!
  end

  def send_to_the_river_stix!
    soul_is_unjudged!
  end

  def ascend!
    soul_has_ascended!
  end

  def condemn!
    soul_in_purgatory!
  end

  def published_date
    published_at.strftime("%B %d, %Y")
  end
end
