class Document < ApplicationRecord
  belongs_to :meeting

  validates :link, presence: true
  validates :title, presence: true

  validates :link, uniqueness: { scope: :meeting_id, case_sensitive: false }

  before_validation :normalize_link!, :squish_title!

  private

  def normalize_link!
    return if link.blank?
    self.link = link.to_s.strip
  end

  def squish_title!
    return if title.blank?
    self.title = title.to_s.strip.squish
  end
end
