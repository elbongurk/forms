class Form < ApplicationRecord
  before_create :assign_uid
  
  belongs_to :user
  has_many :submissions, dependent: :destroy

  validates :name, presence: true

  private

  def assign_uid
    self.uid = SecureRandom.hex(6)
  end
end
