class BatchTradeService
  attr_reader :trader, :currency, :direction
  def initialize(trader:, currency:, direction:)
    @trader = trader
    @currency = currency
    @direction = direction
  end

  def execute
    trader.users.enable.each do |user|
      exchange = user.exchange_class.new(trader, currency)
      order_execution = OrderExecution.create!(
        trader_id: trader.id,
        user_id: user.id,
        currency: currency,
        direction: direction,
        exchange_id: exchange.id
      )
      PlaceOrderJob.perform_async(order_execution.id)
    end
  end
end