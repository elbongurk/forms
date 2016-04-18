class Card < ApplicationRecord
  include Archivable
  include Defaultable

  belongs_to :user
  has_many :charges

  def self.create_for_user_and_token(user, token, other_attributes = {})
    payment_card = self.create_payment_card_for_user_and_token(user, token)
    if payment_card.persisted?
      self.create(payment_card.saved_attributes.merge(other_attributes))
    else
      card = self.new
      card.errors.add(:base, payment_card.error)
      card
    end
  end

  private

  def self.create_payment_card_for_user_and_token(user, token)
    if user.payment_token.present?
      Payment::User.find(user.payment_token).create_card_for_token(token)
    else
      payment_user = Payment::User.create_for_user_and_token(user, token)
      if payment_user.persisted?
        user.update(payment_user.saved_attributes)
      end
      payment_user.cards.first
    end
  end
end
