class Video < ApplicationRecord
  PIPELINE_STATES = {
    failed: -1,
    pending: 0,
    processing: 1,
    skipped: 2,
    retry: 3,
    success: 4
  }.freeze

  enum pipeline: PIPELINE_STATES

  belongs_to :meeting

  validates :external_id, presence: true
end
