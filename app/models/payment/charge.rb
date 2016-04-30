module Payment
  class Charge
    def self.since(time)
      Collection.new(time)
    end

    def self.create_for_subscription_and_card(subscription, card)
      charge = Stripe::Charge.create(
        customer: subscription.user.payment_token,
        source: card.payment_token,
        currency: 'usd',
        amount: subscription.plan.price_in_cents,
        metadata: { subscription_id: subscription.id, card_id: card.id } 
      )
      self.new(charge)
    end

    def initialize(charge)
      @charge = charge
    end

    def saved_attributes
      attributes = {}
      attributes[:payment_token] = @charge.id
      attributes[:subscription_id] = @charge.metadata['subscription_id'].try(:to_i)
      attributes[:card_id] = @charge.metadata['card_id'].try(:to_i)
      attributes[:amount] = @charge.amount
      attributes[:paid] = @charge.paid
      attributes[:failure_code] = @charge.failure_code
      attributes[:failure_message] = @charge.failure_message
      attributes
    end

    class Collection
      def initialize(time)
        @time = time
        @data = {}
      end
      
      def fetch
        @data.clear
        # TODO: Page this
        Stripe::Charge.all(limit: 100, created: { gte: @time.to_i }).each do |charge|
          if key = charge.metadata['subscription_id']
            @data[key.to_i] = Charge.new(charge)
          end
        end
        self
      end

      def find_by_subscription(subscription)
        @data[subscription.id]
      end
    end
  end
end
