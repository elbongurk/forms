class Submission < ApplicationRecord
  belongs_to :form

  validates :payload, presence: true

  def preview
    payload.values.first
  end
end
