class Exchange::Huobi < Exchange::Base
  attr_reader :user, :currency

  def initialize(user, currency)
    @user = user
    @currency = currency
  end

  def balance
    begin
      result = client.contract_balance('USDT')
      balance = result['data'].find {|i| i['valuation_asset'] == 'USDT'}
      balance['balance'].to_d
    rescue
      0.to_d
    end
  end

  def place_order(client_order_id:, volume:, direction:, offset:, lever_rate:)
    result = client.contract_place_order(
      order_id: client_order_id,
      contract_code: contract_code,
      price: nil,
      volume: volume,
      direction: direction,
      offset: offset,
      lever_rate: lever_rate,
      order_price_type: order_price_type
    )
    Exchange::Huobi::PlaceOrderResponse.new(result)
  end

  def order_info(order_id)
    result = client.order_info(contract_code: contract_code, client_order_id: order_id)
    Exchange::Huobi::OrderInfoResponse.new(result)
  end

  def current_position
    Exchange::Huobi::CurrentPositionResponse.new(client.current_position(contract_code))
  end

  def has_position?
    current_position.data.length > 0
  end

  def continuous_fail_times
    latest_profile_order = closed_orders.find {|o| profit?(o)}
    closed_orders.index(latest_profile_order)
  end

  def has_history?
    closed_orders.length > 0
  end

  def last_order_profit?
    profit?(last_closed_order)
  end

  def current_price
    result = client.price_limit(contract_code)
    item = result['data'].find {|i| i['symbol'] == currency}
    raise "price not found #{result}" unless item
    item['high_limit'].to_d
  end

  def contract_size
    client.contract_info(contract_code)['data'].last['contract_size'].to_d
  end

  private
  def closed_orders
    # revere order
    @closed_orders ||=
      begin
        result = client.history(contract_code)['data']['trades']
        result.select {|t| t['offset'] == 'close'}
      end
  end

  def last_closed_order
    # time revere order
    closed_orders.first
  end

  def current_position_response
  end

  def client
    @client ||= HuobiClient.new(user)
  end

  def contract_code
    "#{currency}-USDT"
  end

  def order_price_type
  end

  def profit?(order)
    order['real_profit'] > 0
  end
end
