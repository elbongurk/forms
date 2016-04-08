# Preview all emails at http://localhost:3000/rails/mailers/password_mailer
class PasswordMailerPreview < ActionMailer::Preview
  def reset
    user = User.where.not(password_reset_token: nil).take

    if user.nil?
      user = User.first
      user.set_password_reset
    end
    
    PasswordMailer.reset(user.password_reset_token)
  end

  def changed
    PasswordMailer.changed(User.first.id)
  end
end
