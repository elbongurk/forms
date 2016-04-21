class User < ApplicationRecord
  before_update :clear_password_reset
  before_validation :normalize_email
  
  has_secure_password
  has_many :forms
  has_many :submissions, through: :forms

  has_many :subscriptions
  has_many :charges, through: :subscriptions

  has_many :cards do
    def create_for_token(token, other_attributes = {})
      create_for_user_and_token(self.proxy_association.owner, token, other_attributes)
    end
  end

  validates :email, presence: true, uniqueness: true, email: true
  validates :password_reset_token, uniqueness: true, allow_blank: true

  def self.find_by_normalized_email(email)
    where(email: normalize_email(email)).take
  end
  
  def form_quota_met?
    self.forms.count >= self.plan.form_quota
  end
  
  def plans
    Plan.unarchived.where('form_quota >= ?', self.forms.count)
  end

  def plan
    self.subscriptions.unarchived.take.try(:plan)
  end

  def default_card
    if self.payment_token.present?
      self.cards.unarchived.default.take
    end
  end

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

  def self.normalize_email(email)
    email.to_s.downcase.gsub(/\s+/, "")
  end

  def clear_password_reset
    if self.password_digest_changed?
      self.password_reset_token = nil
      self.password_reset_requested_at = nil
    end
  end

  def normalize_email
    self.email = self.class.normalize_email(email)
  end
end
