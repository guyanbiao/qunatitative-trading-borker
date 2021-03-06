class Exchange::Bitget::CurrentPositionResponse < Exchange::Bitget::BaseResponse
  def lever_rate
    first_order['leverage'].to_i
  end

  def volume
    first_order['position'].to_i
  end

  def direction
    if first_order['holdSide'] == '1'
      'buy'
    else
      'sell'
    end
  end

  def unrealized_profit
    first_order['unrealized_pnl']
  end

  def open_avg_price
    first_order['avg_cost']
  end

  def has_position?
    valid_positions.length > 0
  end

  def currency
    first_order['symbol'].match(/cmt_(.*)usdt/)[1].to_s.upcase
  end

  private
  def first_order
    valid_positions.first
  end

  def valid_positions
    data['holding'].select {|x| x['position'].to_i > 0}
  end
end