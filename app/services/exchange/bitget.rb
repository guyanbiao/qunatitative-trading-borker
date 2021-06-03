class Exchange::Bitget
  attr_reader :user, :currency

  def initialize(user, currency)
    @user = user
    @currency = currency
  end

  def balance
    result = client.accounts
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

  private
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
