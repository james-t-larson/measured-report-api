class Feed < ApplicationRecord
  validates :url, format: URI.regexp(%w[http https]), presence: true, uniqueness: true

  has_many :include_filters, -> { where(function: "include") }, class_name: "FeedFilter"
  has_many :exclude_filters, -> { where(function: "exclude") }, class_name: "FeedFilter"

  has_many :filters, class_name: "FeedFilter", dependent: :destroy
  has_many :feed_entry, dependent: :destroy
  belongs_to :category

  def passes_filters?(entry_text)
    includes_pass = include_filters.empty? || include_filters.any? do |f|
      match = entry_text.match?(/#{Regexp.escape(f.pattern)}/i)
      Rails.logger.debug "[passes_filters] INCLUDE filter '#{f.pattern}' => #{match}"
      match
    end

    excludes_fail = !exclude_filters.empty? && exclude_filters.any? do |f|
      match = entry_text.match?(/#{Regexp.escape(f.pattern)}/i)
      Rails.logger.info "[passes_filters] EXCLUDE filter '#{f.pattern}' => #{match}"
      match
    end

    result = includes_pass && !excludes_fail
    Rails.logger.debug "[passes_filters] Final result => #{result}"
    result
  end
end
