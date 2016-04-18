class Charge < ApplicationRecord
  belongs_to :subscription
  belongs_to :card

  has_many :refunds do
    def create_for_amount!(amount)
      create_for_charge_and_amount!(self.proxy_association.owner, amount)
    end
  end

  def self.create_for_payment_charge!(payment_charge, other_attributes = {})
    self.create!(payment_charge.saved_attributes.merge(other_attributes))
  end

  def self.create_for_subscription_and_card!(subscription, card, other_attributes = {})
    payment_charge = self.create_payment_charge_for_subscription_and_card(subscription, card)
    self.create_for_payment_charge!(payment_charge, other_attributes)
  end
  
  def amount_in_dollars
    self.amount / 100.0
  end

  def refund!(amount_to_refund = nil)
    self.refunds.create_for_amount!(amount_to_refund || self.amount)
  end

  private

  def self.create_payment_charge_for_subscription_and_card(subscription, card)
    Payment::Charge.create_for_subscription_and_card(subscription, card)
  end
end
