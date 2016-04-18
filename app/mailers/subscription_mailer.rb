class SubscriptionMailer < ApplicationMailer
  def unpaid(subscription)
    @subscription = subscription
    @user = subscription.user
    @plan = subscription.plan
    mail(to: @user.email, subject: "Your Forms Subscription")
  end
end
