class Transcript < ApplicationRecord
  belongs_to :meeting

  validates :external_id, uniqueness: { allow_nil: false }
end
