class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_order_percentage, numericality: { greater_than: 0, less_than_or_equal_to: 1 }, allow_nil: true
  validates_uniqueness_of :webhook_token, allow_blank: true
  validates_length_of :webhook_token, minimum: 10, allow_blank: true

  has_many :order_executions

  def exchange_class
    Exchange::Entry.exchanges[exchange_id]
  end

  def exchange_id
    exchange || 'huobi'
  end

  def get_exchange(currency)
    exchange_class.new(self, currency)
  end

  def order_executions
    OrderExecution.where(user_id: id)
  end
end