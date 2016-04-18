namespace :subscriptions do
  desc "Perform charges for paid subscriptions"
  task charge: :environment do
    SubscriptionChargeJob.perform_later(Time.now.utc.to_i) unless QueJob.running?(SubscriptionChargeJob)
  end
end
