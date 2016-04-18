class QueJob < ApplicationRecord
  def self.running?(job_class)
    self.where("args->0->>'job_class' = ?", job_class.to_s).exists?
  end
end
