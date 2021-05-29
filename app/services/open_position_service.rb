class OpenPositionService
  DEFAULT_LEVER_RATE = 100
  DEFAULT_PERCENTAGE = 0.005.to_d
  MAX_CONTINUOUS_FAILURE_TIMES = 5
  attr_reader :user, :currency

  def initialize(user, currency)
    @user = user
    @currency = currency
  end

  def calculate_open_position_volume
    (balance * lever_rate * open_order_percentage / contract_price).round
  end

  def balance
    @balance ||=
      begin
        result = client.contract_balance('USDT')
        balance = result['data'].find {|i| i['valuation_asset'] == 'USDT'}
        balance['balance'].to_d
      rescue
        0.to_d
      end
  end

  def lever_rate
    @lever_rate ||= user.lever_rate || DEFAULT_LEVER_RATE
  end

  def close_orders
    # revere order
    @close_orders ||=
      begin
        result = client.history(contract_code)['data']['trades']
        result.select {|t| t['offset'] == 'close'}
      end
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
        return default_percentage unless close_orders.length > 0

        if profit?(last_order)
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
    client.contract_info(contract_code)['data'].last['contract_size'].to_d
  end

  def contract_code
    "#{currency}-USDT"
  end

  def default_percentage
    @default_percentage ||= user.first_order_percentage || DEFAULT_PERCENTAGE
  end

  def continuous_fail_times
    latest_profile_order = close_orders.find {|o| profit?(o)}
    close_orders.index(latest_profile_order)
  end

  def last_finished_close_order
    @last_close_order ||= query_service.last_finished_close_order(contract_code: contract_code, user_id: user.id)
  end

  private
  def client
    @client ||= HuobiClient.new(user)
  end

  def information
    @information ||= HuobiInformationService.new(user, currency)
  end

  def query_service
    Query::UsdtStandardOrderService.new
  end
end