class Category < ApplicationRecord
  has_many :articles, dependent: :destroy
  has_many :feed_entries, dependent: :destroy

  validates :slug, uniqueness: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
