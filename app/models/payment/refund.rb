module Payment
  class Refund
    def self.create_for_charge_and_amount(charge, amount)
      refund = Stripe::Refund.create(
        charge: charge.payment_token,
        amount: amount,
        metadata: { charge_id: charge.id }
      )
      self.new(refund)
    end

    def initialize(refund)
      @refund = refund
    end

    def saved_attributes
      attributes = {}
      attributes[:payment_token] = @refund.id
      attributes[:amount] = @refund.amount
      attributes[:charge_id] = @refund.metadata['charge_id'].try(:to_i)
      attributes
    end
  end
end
