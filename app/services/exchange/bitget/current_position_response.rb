class Exchange::Bitget::CurrentPositionResponse < Exchange::Bitget::BaseResponse
  def lever_rate
    first_order['leverage']
  end

  def volume
    first_order['position'].to_i
  end

  def direction
    if first_order['holdSide']
      'buy'
    else
      'sell'
    end
  end

  def has_position?
    valid_positions.length > 0
  end

  private
  def first_order
    valid_positions.first
  end

  def valid_positions
    data['holding'].select {|x| x['position'].to_i > 0}
  end
end
