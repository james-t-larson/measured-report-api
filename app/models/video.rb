class Video < ApplicationRecord
  PIPELINE_STATES = {
    no_transcript: -2,
    no_details: -1,
    needs_details: 0,
    needs_transcript: 1,
    retry_details: 2,
    retry_transcript: 3,
    complete: 4
  }.freeze

  enum pipeline: PIPELINE_STATES

  belongs_to :meeting
  has_one :transcripts

  validates :external_id, presence: true
end
