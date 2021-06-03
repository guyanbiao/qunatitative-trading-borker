class Exchange::Huobi::CurrentPositionResponse < Exchange::Huobi::BaseResponse
  def lever_rate
    first_order['lever_rate']
  end

  def volume
    first_order['volume'].to_i
  end

  def direction
    first_order['direction']
  end

  private

  def first_order
    data.first
  end
end
