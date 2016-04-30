class SubscriptionRenewJob < ApplicationJob
  INTERVAL = 1.hour

  # Creates the very first renew job
  def self.seed
    tf = Time.now
    t0 = tf - INTERVAL
    self.perform_later(t0.to_f, tf.to_f)
  end
  
  def perform(start_at_tick, end_at_tick)
    start_at, end_at = Time.at(start_at_tick), Time.at(end_at_tick)
    time_range = start_at...end_at
    run_again_at = end_at + self.class::INTERVAL
    
    Subscription.unarchived.renewable.ending(time_range).includes(:plan).each do |subscription|
      if subscription.cancel_at_period_end?
        subscription.cancel!
      else
        subscription.renew!
      end
    end

    SubscriptionChargeJob.perform_later(start_at.to_f, end_at.to_f)    
    SubscriptionRenewJob.set(wait_until: run_again_at).perform_later(end_at.to_f, run_again_at.to_f)
  end
end
