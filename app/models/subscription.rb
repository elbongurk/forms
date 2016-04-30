class Subscription < ApplicationRecord
  include Archivable

  belongs_to :user
  belongs_to :plan

  has_many :charges do
    def create_for_card!(card, other_attributes = {})
      create_for_subscription_and_card!(self.proxy_association.owner, card, other_attributes)
    end
  end

  enum status: [ :trial, :paid, :unpaid, :comped ]

  def self.starting(time_range)
    where(period_start: time_range)
  end

  def self.ending(time_range)
    where(period_end: time_range)
  end

  def self.chargable
    where(status: :unpaid)
  end
  
  def self.renewable
    where(status: [:trial, :paid])
  end

  def self.build_unpaid_for_plan(plan)
    self.build_status_for_plan(:unpaid, plan)
  end

  def self.build_trial_for_plan(plan)
    self.build_status_for_plan(:trial, plan)
  end

  def self.create_unpaid_for_plan(plan)
    self.create_status_for_plan(:unpaid, plan)
  end

  def self.create_trial_for_plan(plan)
    self.create_status_for_plan(:trial, plan)
  end

  def build_switch_to_plan(plan, other_attributes = {})
    status = status_for_switch
    attributes = {}
    attributes[:user_id] = self.user_id
    attributes[:period_end] = self.period_end if self.period_end.present?
    self.class.build_status_for_plan(status, plan, attributes.merge(other_attributes))
  end

  def build_renewal
    attributes = {}
    attributes[:user_id] = self.user_id
    attributes[:period_start] = self.period_end if self.period_end.present?
    subscription = self.class.build_status_for_plan(:unpaid, self.plan, attributes)
  end

  def switch_to_plan!(plan, other_attributes = {})
    switch_to_subscription!(build_switch_to_plan(plan, other_attributes))
  end  

  def renew!
    switch_to_subscription!(build_renewal)
  end

  def cancel!
    self.archive!(ended_at: Time.now.utc)
  end

  def billable_on
    if self.unpaid?
      self.period_start
    else
      self.period_end
    end
  end

  private

  def self.build_status_for_plan(status, plan, other_attributes = {})
    period_start = other_attributes[:period_start] || Time.now.utc
    attributes = {}
    attributes[:status] = status
    attributes[:plan] = plan
    attributes[:period_start] = period_start
    attributes[:period_end] = period_start + plan.duration_for_status(status)
    if self.respond_to?(:build)
      self.build(attributes.merge(other_attributes))
    else
      self.new(attributes.merge(other_attributes))
    end
  end

  def self.create_status_for_plan(status, plan, other_attributes = {})
    subscription = self.build_status_for_plan(status, plan, other_attributes)
    subscription.save
    subscription
  end

  def switch_to_subscription!(subscription)
    self.transaction do
      self.cancel!
      subscription.save!
    end
    subscription
  end

  def status_for_switch
    if self.paid?
      :paid
    else
      :unpaid
    end
  end
end
