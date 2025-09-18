class Meeting < ApplicationRecord
  has_many :videos,    inverse_of: :meeting, dependent: :destroy
  has_many :documents, inverse_of: :meeting, dependent: :destroy
  has_many :transcripts, through: :videos

  validates :external_id, presence: true
  validates :title, presence: true

  scope :most_recent, -> { order(start_datetime: :desc) }

  def references
    [ documents, videos ].flatten
  end
end
