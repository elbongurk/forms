class SubscriptionsController < ApplicationController
  before_action :require_authorization

  def show    
    @subscription = current_user.subscriptions.unarchived.take
    @plan = current_user.plan
    @plans = current_user.plans
    @cards = current_user.cards.unarchived
  end
  
  def new
    @plan = current_user.plans.where(name: params[:plan]).take
    @subscription = @plan.build_subscription_for_user(current_user)
  end

  def create
    @plan = current_user.plans.where(name: params[:plan]).take
    @subscription = @plan.create_subscription_for_user(current_user)

    redirect_to account_subscription_url
  end

  def update
    subscription = current_user.subscriptions.unarchived.take
    subscription.update(update_params)

    redirect_to account_subscription_url
  end

  private

  def update_params
    params.require(:subscription).permit(:cancel_at_period_end)
  end
end
