class SubscriptionRenewJob < ApplicationJob
  def perform
    Subscription.unarchived.renewable.ending.includes(:plan).each do |subscription|
      if subscription.cancel_at_period_end
        subscription.cancel!
      else
        subscription.renew!
      end
    end
  end
end
