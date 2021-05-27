class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_order_percentage, numericality: { greater_than: 0, less_than_or_equal_to: 1 }, allow_nil: true
  validates_uniqueness_of :webhook_token
  validates_length_of :webhook_token, minimum: 10
end