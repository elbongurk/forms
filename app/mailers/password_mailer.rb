class PasswordMailer < ApplicationMailer
  def reset(user_password_reset_token)
    @user = User.where(password_reset_token: user_password_reset_token).take!
    mail(to: @user.email, subject: "Password Reset")
  end

  def changed(user_id)
    @user = User.where(id: user_id).take!
    mail(to: @user.email, subject: "Password Changed")
  end
end
