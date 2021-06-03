class Exchange::Bitget::PlaceOrderResponse < Exchange::Bitget::BaseResponse
  def order_id
    response['order_id']
  end
end
