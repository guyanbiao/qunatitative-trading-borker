class Exchange::Bitget
  attr_reader :user, :currency

  def initialize(user, currency)
    @user = user
    @currency = currency
  end

  def balance
    result = client.accounts['data']
    item = result.find {|x| x['symbol'] == symbol}
    return 0 unless item
    item['total_avail_balance'].to_d
  end

  def place_order(client_order_id:, volume:, direction:, offset:, lever_rate: nil)
    result = client.place_order(
      symbol: symbol,
      client_order_id: client_order_id,
      price: nil,
      size: volume,
      type: type(offset, direction),
      order_type: order_type,
      match_price: match_price,
    )
    Exchange::Bitget::PlaceOrderResponse.new(result)
  end

  def order_info(remote_order_id)
    result = client.order_info(symbol: symbol, remote_order_id: remote_order_id)
    Exchange::Bitget::OrderInfoResponse.new(result)
  end

  def current_position
    Exchange::Bitget::CurrentPositionResponse.new(client.current_position(contract_code))
  end

  def has_position?
    current_position.has_position?
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
    result = client.ticker(symbol)
    result['data']['best_ask']
  end

  def contract_size
    result = client.contracts_info
    item = result['data'].find {|i| i['symbol'] == symbol}
    raise "price not found #{result}" unless item
    item['contract_val'].to_d
  end

  private
  def profit?(order)
    order['totalProfits'] > 0
  end

  def last_closed_order
    # time revere order
    closed_orders.first
  end

  def closed_orders
    client.history(symbol: symbol)['data'].select do |x|
      x['status'] == 2 && (x['type'] == 3 || x['type'] == 4)
    end
  end

  def order_type
    # 0:普通，1：只做maker;2:全部成交或立即取消;3:立即成交并取消剩余
    0
  end

  def match_price
    # 0:限价还是1:市价
    1
  end

  def type(offset, direction)
    # type 1:开多 2:开空 3:平多 4:平空
    case [offset, direction]
    when %w[open buy]
      # 开多
      1
    when %w[open sell]
      # 开空
      2
    when %w[close sell]
      # 平多
      3
    when %w[close buy]
      # 平空
      4
    end
  end

  def client
    @client = BitGetApiClient.new(user)
  end

  def symbol
    "cmt_#{currency.downcase}usdt"
  end
end
