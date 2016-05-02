class Form < ApplicationRecord
  before_create :assign_uid
  
  belongs_to :user
  has_many :submissions, dependent: :destroy

  validates :name, presence: true

  def additional_emails=(value)
    case value
    when String
      super(value.downcase.split(/[,\s]+/) - [''])
    else
      super(value)
    end
  end

  private

  def assign_uid
    self.uid = SecureRandom.hex(6)
  end
end
