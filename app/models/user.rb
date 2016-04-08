class User < ApplicationRecord
  before_update :clear_password_reset
  
  has_secure_password
  has_many :forms
  has_many :submissions, through: :forms

  validates :email, presence: true, uniqueness: true, email: true
  validates :password_reset_token, uniqueness: true

  def password_resettable?
    self.password_reset_token && self.password_reset_requested_at &&
      self.password_reset_requested_at.utc >= 6.hours.ago.utc
  end

  def reset_password(password)
    if password_resettable?
      self.password = password
      self.save
    end
  end
  
  def set_password_reset_request
    token, time = SecureRandom.hex(6), Time.now.utc
    
    self.password_reset_token = token
    self.password_reset_requested_at = time

    self.save
  end
  
  private

  def clear_password_reset
    if self.password_digest_changed?
      self.password_reset_token = nil
      self.password_reset_requested_at = nil
    end
  end
end
