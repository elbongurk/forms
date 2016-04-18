class SubscriptionChargeJob < ApplicationJob
  def perform(tick)
    payment_charges = Payment::Charge.since(tick).fetch

    Subscription.unarchived.unpaid.includes(:plan, :user).each do |subscription|
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
        subscription.transaction do
          process_charge_for_subscription(nil, subscription)
        end
      end
    end
  end

  private

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
