class Exchange::Bitget::OrderInfoResponse < Exchange::Bitget::BaseResponse

  def order_placed?
    # 订单状态( -1:撤销成功 0:等待成交 1:部分成交 2:完全成交)
    success? && data['status'] == ::Exchange::Bitget::OrderStatus::ORDER_FINISHED_STATUS
  end

  def profit
    data['totalProfits'].to_d
  end

  def real_profit
    data['totalProfits'].to_d
  end

  def trade_avg_price
    data['price_avg'].to_d
  end

  def fee
    data['fee'].to_d
  end

  def status
    data['status']
  end

  def price
    data['price'].to_d
  end
end