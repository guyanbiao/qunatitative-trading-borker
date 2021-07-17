class Trader < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :users
  has_many :manual_batch_executions
end
