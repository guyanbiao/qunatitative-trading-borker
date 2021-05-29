class RemoteUsdtStandardOrder
  attr_reader :id, :user_id, :order_price_type, :contract_code, :lever_rate, :volume, :direction

  def initialize(id:, user_id:, contract_code:, lever_rate:, volume:, direction:)
    @id  = id
    @user_id =  user_id
    @order_price_type = order_price_type
    @contract_code = contract_code
    @lever_rate  = lever_rate
    @volume = volume
    @direction  = direction
  end
end