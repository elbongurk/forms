class Refund < ApplicationRecord
  belongs_to :charge

  def self.create_for_charge_and_amount!(charge, amount, other_attributes = {})
    payment_refund = self.create_payment_refund_for_charge_and_amount(charge, amount)
    self.create!(payment_refund.saved_attributes.merge(other_attributes))
  end
  
  def amount_in_dollars
    self.amount / 100.0
  end

  private

  def self.create_payment_refund_for_charge_and_amount(charge, amount)
    Payment::Refund.create_for_charge_and_amount(charge, amount)
  end
end
