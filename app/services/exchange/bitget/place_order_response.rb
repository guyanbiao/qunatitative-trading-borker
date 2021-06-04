class Exchange::Bitget::PlaceOrderResponse < Exchange::Bitget::BaseResponse
  def order_id
    data['order_id']
  end
end
