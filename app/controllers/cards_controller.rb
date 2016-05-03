class CardsController < ApplicationController
  before_action :require_authorization

  def index
    @cards = current_user.cards.unarchived
  end

  def new
    @card = current_user.cards.new
    if params[:plan].present?
      @plan = current_user.plans.where(name: params[:plan]).take
      @subscription = @plan.try(:build_subscription_for_user, current_user)
    else
      @subscription = current_user.subscriptions.unarchived.where.not(status: :comped).take
      @plan = @subscription.try(:plan)
    end
  end

  def create
    @card = current_user.cards.create_for_token(params[:token], default: true)
    
    if @card.persisted?
      if params[:plan].present?
        if plan = current_user.plans.where(name: params[:plan]).take
          plan.create_subscription_for_user(current_user) unless plan == current_user.plan
        end
        redirect_to account_subscription_url
      else
        redirect_to account_cards_url
      end
    else
      if params[:plan].present?
        @plan = current_user.plans.where(name: params[:plan]).take
        @subscription = @plan.try(:build_subscription_for_user, current_user)
      else
        @subscription = current_user.subscriptions.unarchived.where.not(status: :comped).take
        @plan = @subscription.try(:plan)
      end
      render action: :new
    end
  end

  def destroy
    card = current_user.cards.unarchived.where(id: params[:id]).take

    card.archive!

    redirect_to account_cards_url
  end
end
