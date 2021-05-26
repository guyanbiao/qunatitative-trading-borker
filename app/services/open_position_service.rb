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

  def open_order_percentage
    @open_order_percentage ||=
      begin
        return default_percentage unless last_order

        if last_order.profit?
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
    profit_order_id = UsdtStandardOrder.where(user_id: user.id).where("real_profit > 0").order(:created_at).last&.id || 0
    UsdtStandardOrder.open.where("id > ?", profit_order_id).count
  end
  private
  def client
    @client ||= HuobiClient.new(user)
  end

  def information
    @information ||= HuobiInformationService.new(user, currency)
  end

  def last_order
    @last_order ||= UsdtStandardOrder.order(:created_at).open.where(user_id: user.id).last
  end
end