class Plan < ApplicationRecord
  include Archivable
  include Defaultable
  
  has_many :subscriptions
  has_many :users, through: :subscriptions

  def self.find_by_name_or_default(name)
    if plan = where(name: name).take
      plan
    else
      where(default: true).take
    end
  end
  
  def price_in_cents
    self.price * 100
  end

  def duration_for_status(status)
    case status
    when :trial
      self.trial_period_days.days
    else
      1.month
    end    
  end

  def create_subscription_for_user(user)
    if subscription = user.subscriptions.unarchived.take
      subscription.switch_to_plan!(self)
    else
      user.subscriptions.create_unpaid_for_plan(self)
    end
  end

  def build_subscription_for_user(user)
    if subscription = user.subscriptions.unarchived.take
      subscription.build_switch_to_plan(self)
    else
      user.subscriptions.build_unpaid_for_plan(self)
    end
  end
end
