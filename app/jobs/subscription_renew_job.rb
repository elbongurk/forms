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

    perform_renewal_for_range(time_range)
    perform_charges_for_range(time_range)

    run_again_at = end_at + self.class::INTERVAL
    SubscriptionRenewJob.set(wait_until: run_again_at).perform_later(end_at.to_f, run_again_at.to_f)
  end

  private

  def perform_renewal_for_range(time_range)
    Subscription.unarchived.renewable.ending(time_range).includes(:plan).each do |subscription|
      if subscription.cancel_at_period_end?
        subscription.cancel!
      else
        subscription.renew!
      end
    end
  end

  def perform_charges_for_range(time_range)
    payment_charges = Payment::Charge.since(time_range.last).fetch

    Subscription.unarchived.chargable.starting(time_range).includes(:plan, :user).each do |subscription|
      if payment_charge = payment_charges.find_by_subscription(subscription)
        subscription.transaction do
          charge = subscription.charges.create_for_payment_charge!(payment_charge)
          process_charge_for_subscription(charge, subscription)
        end
      elsif card = subscription.user.default_card
        subscription.transaction do
          charge = subscription.charges.create_for_card!(card)
          process_charge_for_subscription(charge, subscription)
        end
      else
        process_charge_for_subscription(nil, subscription)
      end
    end
  end

  def process_charge_for_subscription(charge, subscription)
    if charge.try(:paid?)
      subscription.paid!
      ChargeMailer.paid(charge).deliver_later
    else
      subscription.cancel!
      SubscriptionMailer.unpaid(subscription).deliver_later
    end
  end
end
