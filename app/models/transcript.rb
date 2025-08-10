class Transcript < ApplicationRecord
  PIPELINE_STATES = {
    failed: -1,
    pending: 0,
    processing: 1,
    skipped: 2,
    retry: 3,
    success: 4
  }.freeze

  enum pipeline: PIPELINE_STATES

  belongs_to :video

  validates :external_id, uniqueness: { allow_nil: false }
end
