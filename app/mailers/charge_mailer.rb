class ChargeMailer < ApplicationMailer
  def paid(charge)
    @charge = charge
    @card = charge.card
    @subscription = charge.subscription
    @user = @subscription.user
    @plan = @subscription.plan
    mail(to: @user.email, subject: "Elbongurk Forms Receipt")
  end
end
