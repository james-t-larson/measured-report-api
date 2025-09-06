class Video < ApplicationRecord
  # TODO: Add validations for each pipeline status
  # Example: cannot be moved into failed if it has a title and link
  # Or: cannot be set to complete if title or link have not been added
  #
  # TODO: the link can be added without getting it from Vimeo

  PIPELINE_STATES = {
    failed: -1,
    pending: 0,
    retry: 2,
    complete: 4
  }.freeze

  enum pipeline: PIPELINE_STATES

  belongs_to :meeting
  has_one :transcript, inverse_of: :video, dependent: :destroy

  validates :external_id, presence: true
  validate :ensure_metadata, if: -> {
    will_save_change_to_pipeline? && pipeline_change_to_be_saved&.last == "complete"
  }

  scope :in_progress, -> { where(pipeline: [ :pending, :retry ]) }

  private

  def ensure_metadata
    errors.add(:pipeline, "cannot be set to complete unless all metadata is present") if title.blank? || link.blank? || transcript.blank?
  end
end
