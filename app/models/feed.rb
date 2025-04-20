class Feed < ApplicationRecord
  validates :url, presence: true, uniqueness: true
  validate :url_must_be_valid

  has_many :feed_entry
  belongs_to :category

  private

  def url_must_be_valid
    uri = URI.parse(url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      errors.add(:url, "must be a valid HTTP or HTTPS URL")
    end
  rescue URI::InvalidURIError
    errors.add(:url, "is not a valid URI")
  end
end
