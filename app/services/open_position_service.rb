class OpenPositionService
  DEFAULT_LEVER_RATE = 100
  DEFAULT_PERCENTAGE = 0.005.to_d
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
    @open_order_percentage ||=
      begin
        return default_percentage unless exchange.has_history?

        if exchange.last_order_profit?
          default_percentage
        else
          if continuous_fail_times > MAX_CONTINUOUS_FAILURE_TIMES
            default_percentage
          else
            (continuous_fail_times + 1) *  default_percentage
          end
        end
      end
  end

  def contract_price
    @contract_price ||= current_price * contract_unit_price
  end

  def current_price
    @current_price ||= information.current_price
  end

  def contract_unit_price
    information.contract_unit_price
  end

  def contract_code
    "#{currency}-USDT"
  end

  def default_percentage
    @default_percentage ||= user.first_order_percentage || DEFAULT_PERCENTAGE
  end

  def continuous_fail_times
    exchange.continuous_fail_times
  end

  def last_finished_close_order
    @last_close_order ||= query_service.last_finished_close_order(contract_code: contract_code, user_id: user.id)
  end

  private
  def information
    @information ||= HuobiInformationService.new(user, currency)
  end

  def query_service
    Query::UsdtStandardOrderService.new
  end
end