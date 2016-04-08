# Preview all emails at http://localhost:3000/rails/mailers/password_mailer
class PasswordMailerPreview < ActionMailer::Preview
  def requested_by_user
    PasswordMailer.requested_by_user(User.first)
  end

  def reset_by_user
    PasswordMailer.reset_by_user(User.first)
  end
end
