module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where(archived: true) }
    scope :unarchived, -> { where(archived: false) }
  end

  def archive(args = {})
    self.update(args.merge(archived: true))
  end
  
  def archive!(args = {})
    self.update!(args.merge(archived: true))
  end
end
