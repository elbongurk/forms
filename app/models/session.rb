class Session
  include ActiveModel::Model

  attr_accessor :email, :password
  
  validates :email, presence: true, email: true
  validates :password, presence: true
  
  def authenticate
    if valid?
      if user = User.where(email: email).take
        return user if user.authenticate(password)
      end
    end
  end
end
