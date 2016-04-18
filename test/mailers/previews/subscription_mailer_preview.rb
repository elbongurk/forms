# Preview all emails at http://localhost:3000/rails/mailers/subscription_mailer
class SubscriptionMailerPreview < ActionMailer::Preview
  def unpaid
    SubscriptionMailer.unpaid(Subscription.first)
  end
end
