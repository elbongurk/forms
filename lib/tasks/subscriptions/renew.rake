namespace :subscriptions do
  desc "Renew subscriptions at end of period"
  task renew: :environment do    
    SubscriptionRenewJob.perform_later unless QueJob.running?(SubscriptionRenewJob)
  end
end
