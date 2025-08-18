class Transcript < ApplicationRecord
  PIPELINE_STATES = {
    no_vtt: -1,
    needs_vtt: 0,
    retry: 1,
    complete: 2
  }.freeze

  enum pipeline: PIPELINE_STATES

  belongs_to :video

  validates :external_id, uniqueness: { allow_nil: false }

  scope :in_progress, -> { where(pipeline: [ :needs_vtt, :retry ]) }
end
