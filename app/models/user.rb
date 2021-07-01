class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_order_percentage, numericality: { greater_than: 0, less_than_or_equal_to: 1 }, allow_nil: true
  validates_uniqueness_of :webhook_token, allow_blank: true
  validates_length_of :webhook_token, minimum: 10, allow_blank: true

  has_many :order_executions
  has_many :history_orders
  belongs_to :trader, optional: true
  scope :enable, -> {where(enable: true)}

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

  def supported_exchanges
    exchanges = []

    # exchanges << 'huobi' if huobi_access_key.present? && huobi_secret_key.present?
    exchanges << 'bitget' if bitget_access_key.present? && bitget_pass_phrase.present? && bitget_secret_key.present?
    exchanges
  end
end