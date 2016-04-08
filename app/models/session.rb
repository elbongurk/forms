class Session
  include ActiveModel::Model

  attr_accessor :email, :password
  
  validates :email, presence: true, email: true
  validates :password, presence: true
  
  def authenticate
    if valid?
      if user = User.where(email: email).take
        if user.authenticate(password)
          return user
        else
          errors[:password] << "does not appear to be correct"
        end
      else
        errors[:email] << "does not have an account"
      end
    end
    return nil
  end
end
