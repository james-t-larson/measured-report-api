class FeedFilter < ApplicationRecord
  belongs_to :feed

  validates :pattern, presence: true
  validates :function, inclusion: { in: %w[include exclude] }
end
