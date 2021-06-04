class Exchange::Bitget::OrderInfoResponse < Exchange::Bitget::BaseResponse
  ORDER_FINISHED_STATUS = 2
  def order_placed?
    # 订单状态( -1:撤销成功 0:等待成交 1:部分成交 2:完全成交)
    success? && data['status'] == ORDER_FINISHED_STATUS
  end

  def profit
    data['totalProfits']
  end

  def real_profit
    data['totalProfits']
  end

  def trade_avg_price
    data['price_avg']
  end

  def fee
    data['fee']
  end

  def status
    data['status']
  end

  def price
    data['price']
  end
end