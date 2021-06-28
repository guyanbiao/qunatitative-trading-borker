class OpenPositionService
  DEFAULT_LEVER_RATE = 100
  MAX_CONTINUOUS_FAILURE_TIMES = 5
  attr_reader :user, :currency, :exchange

  def initialize(user, currency, exchange)
    @user = user
    @currency = currency
    @exchange = exchange
  end

  def calculate_open_position_volume
    (balance * lever_rate * open_order_percentage / contract_price).round
  end

  def balance
    exchange.balance
  end

  def lever_rate
    @lever_rate ||= user.lever_rate || DEFAULT_LEVER_RATE
  end

  def close_orders
    exchange.orders_closed
  end

  def last_order
    # time revere order
    close_orders.first
  end

  def profit?(order)
    order['real_profit'] > 0
  end

  def open_order_percentage
    @open_order_percentage ||= TradingStrategyService.new(trader: user.trader, exchange: exchange).open_order_percentage
  end

  def contract_price
    @contract_price ||= current_price * contract_size
  end

  def current_price
    @current_price ||= exchange.current_price
  end

  def contract_size
    exchange.contract_size
  end

  def contract_code
    "#{currency}-USDT"
  end

  def last_finished_close_order
    @last_close_order ||= query_service.last_finished_close_order(contract_code: contract_code, user_id: user.id)
  end

  private

  def query_service
    Query::UsdtStandardOrderService.new
  end
end