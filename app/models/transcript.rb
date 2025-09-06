class Transcript < ApplicationRecord
  PIPELINE_STATES = {
    failed: -1,
    pending: 0,
    retry: 2,
    complete: 3
  }.freeze

  enum pipeline: PIPELINE_STATES

  belongs_to :video

  validates :external_id, uniqueness: { allow_nil: false }
  validate :ensure_vtt, if: -> {
    will_save_change_to_pipeline? && pipeline_change_to_be_saved&.last == "complete"
  }

  scope :in_progress, -> { where(pipeline: [ :pending, :retry ]) }

  private

  def ensure_vtt
    errors.add(:pipeline, "cannot be set to complete unless vtt present") if vtt.blank?
  end
end
