class Password
  include ActiveModel::Model

  attr_accessor :email, :password, :password_reset_token

  validates :email, presence: true, email: true, on: :reset
  validates :password, presence: true, on: :update
  validates :password_reset_token, presence: true, on: :update

  def to_param    
    self.password_reset_token
  end

  def persisted?
    self.password_reset_token.present?
  end
  
  def reset
    if valid?
      if user = User.where(email: email).take
        return user.send_password_reset
      else
        errors[:email] << "does not have an account"
      end
    end
    return nil
  end

  def update
    if valid?
      user = User.where(password_reset_token: password_reset_token).take
      if user && user.change_password(password)
        return user
      else
        errors[:base] << "Request is no longer valid"
      end
    end
    return nil
  end
end
