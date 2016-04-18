module Payment
  class Card
    def initialize(card, persisted = true, error = nil)
      @card = card
      @persisted = persisted
      @error = error
    end

    def persisted?
      @persisted
    end

    def error
      @error
    end

    def saved_attributes
      attributes = {}
      attributes[:payment_token] = @card.id
      attributes[:brand] = @card.brand
      attributes[:last4] = @card.last4
      attributes[:exp_month] = @card.exp_month
      attributes[:exp_year] = @card.exp_year
      attributes[:name] = @card.name
      attributes
    end
  end
end
