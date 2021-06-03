class Exchange::Huobi::PlaceOrderResponse < Exchange::Huobi::BaseResponse
  def order_id
    response['data']['order_id']
  end
end