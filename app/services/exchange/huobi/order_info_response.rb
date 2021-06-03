class Exchange::Huobi::OrderInfoResponse < Exchange::Huobi::BaseResponse
  def order_placed?
    success? && status == UsdtStandardOrder::RemoteStatus::FINISHED
  end

  def profit
    currency_data['profit']
  end

  def real_profit
    currency_data['real_profit']
  end

  def trade_avg_price
    currency_data['trade_avg_price']
  end

  def fee
    currency_data['fee']
  end

  def status
    currency_data['status']
  end

  def price
    currency_data['price']
  end

  private
  def currency_data
    data.first
  end
end