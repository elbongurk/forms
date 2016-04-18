class CardsController < ApplicationController
  before_action :require_authorization

  def index
    @user = current_user
    @cards = current_user.cards.unarchived
  end

  def new
    @user = current_user
    @card = current_user.cards.new
    @plan = current_user.plans.where(name: params[:plan]).take
  end

  def create
    @user = current_user
    @card = current_user.cards.create_for_token(params[:token], default: true)
    @plan = current_user.plans.where(name: params[:plan]).take

    if @card.persisted?
      if @plan
        @plan.create_subscription_for_user(@user)
        redirect_to account_subscription_url
      else
        redirect_to account_cards_url
      end
    else
      render action: :new
    end
  end

  def destroy
    card = current_user.cards.unarchived.where(id: params[:id]).take

    card.archive!

    redirect_to account_cards_url
  end
end
