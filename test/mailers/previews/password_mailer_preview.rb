# Preview all emails at http://localhost:3000/rails/mailers/password_mailer
class PasswordMailerPreview < ActionMailer::Preview
  def requested_by_user
    user = User.first
    user.password_reset_token = SecureRandom.hex(6)
    PasswordMailer.requested_by_user(user)
  end

  def reset_by_user
    PasswordMailer.reset_by_user(User.first)
  end
end
