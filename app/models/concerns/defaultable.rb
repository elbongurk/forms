module Defaultable
  extend ActiveSupport::Concern

  included do
    before_save :update_defaultable_on_save
    before_destroy :update_defaultable_on_destroy

    scope :default, -> { where(default: true) }
  end

  protected

  def update_defaultable_on_save
    if self.default?
      if self.try(:archived?)
        if self.archived_changed? && !self.new_record?
          set_fallback_default
        end
      else
        clear_other_defaults
      end
    else
      set_default unless self.try(:archived?)
    end
  end

  def update_defaultable_on_destroy
    if self.default?
      set_fallback_default unless self.try(:archived?)
    end
  end

  private

  def clear_other_defaults
    other_defaults = self.class.where(default: true)
    other_defaults = other_defaults.where(user_id: self.user_id) if self.respond_to?(:user_id)
    other_defaults = other_defaults.where(archived: false) if self.respond_to?(:archived)
    other_defaults.update_all(default: false)
  end
  
  def set_default
    current_default = self.class.where(default: true)
    current_default = current_default.where(user_id: self.user_id) if self.respond_to?(:user_id)
    current_default = current_default.where(archived: false) if self.respond_to?(:archived)
    self.default = !current_default.exists?
  end

  def set_fallback_default
    fallback_default = self.class.order(updated_at: :desc).where(default: false)
    fallback_default = fallback_default.where(user_id: self.user_id) if self.respond_to?(:user_id)
    fallback_default = fallback_default.where(archived: false) if self.respond_to?(:archived)
    if fallback = fallback_default.take
      fallback.update_column(:default, true)
    end
  end
end
