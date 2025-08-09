class Video < ApplicationRecord
  belongs_to :meeting

  validates :external_id, presence: true
end
