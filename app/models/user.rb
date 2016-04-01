class User < ApplicationRecord
  has_secure_password
  has_many :forms
  has_many :submissions, through: :forms

  validates :email, presence: true, uniqueness: true, email: true
end
