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

  # 成交均价
  def trade_avg_price
    currency_data['trade_price']
  end

  def fee
    currency_data['trade_fee']
  end

  def status
    currency_data['status']
  end

  def price
    currency_data['price']
  end

  def symbol
    currency_data['contract_code']
  end

  def closed_volume
    currency_data['trade_volume']
  end

  def created_at
    Time.at(currency_data['create_date'].to_f / 1000)
  end

  private
  def currency_data
    data.first
  end
end