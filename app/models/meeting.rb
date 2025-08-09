class Meeting < ApplicationRecord
  PIPELINE_STATES = {
    failed: -1,
    pending: 0,
    processing: 1,
    skipped: 2,
    retry: 3,
    success: 4
  }.freeze

  enum document_pipeline: PIPELINE_STATES, _prefix: :document
  enum video_pipeline: PIPELINE_STATES, _prefix: :video
  enum transcript_pipeline: PIPELINE_STATES, _prefix: :transcript

  has_many :videos, dependent: :destroy
  has_many :transcripts, dependent: :destroy
  has_many :documents, dependent: :destroy

  validates :external_id, presence: true
  validates :title, presence: true
end
