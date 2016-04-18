module Payment
  class User
    def self.find(token)
      User.new(Stripe::Customer.retrieve(token))
    end

    def self.create_for_user_and_token(user, token)
      if token.present?
        begin
          customer = Stripe::Customer.create(
            source: token,
            email: user.email,
            metadata: { user_id: user.id }
          )
          User.new(customer)
        rescue Stripe::CardError => e
          User.new(Stripe::Customer.new, false, e.message)
        rescue Stripe::StripeError => e
          # TODO: log this to exception monitor
          User.new(Stripe::Customer.new, false, "Unable to add card")
        end
      else
        User.new(Stripe::Customer.new, false, "Unable to add card")
      end
    end

    def initialize(user, persisted = true, error = nil)
      @user = user
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
      attributes[:payment_token] = @user.id
      attributes
    end

    def cards
      if self.persisted?
        @user.sources.map { |s| Payment::Card.new(s) }
      else
        [ Payment::Card.new(Stripe::Card.new, false, self.error) ]
      end
    end

    def create_card_for_token(token)
      if token.present?
        begin
          Payment::Card.new(@user.sources.create(source: token))
        rescue Stripe::CardError => e
          Payment::Card.new(Stripe::Card.new, false, e.message)
        rescue Stripe::StripeError => e
          # TODO: log this to exception monitor
          Payment::Card.new(Stripe::Card.new, false, "Unable to add card")
        end
      else
        Payment::Card.new(Stripe::Card.new, false, "Unable to add card")
      end
    end
  end
end
