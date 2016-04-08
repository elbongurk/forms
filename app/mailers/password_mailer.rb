class PasswordMailer < ApplicationMailer
  def requested_by_user(user)
    @user = user
    mail(to: @user.email, subject: "Password Reset")
  end

  def reset_by_user(user)
    @user = user
    mail(to: @user.email, subject: "Password Changed")
  end
end
