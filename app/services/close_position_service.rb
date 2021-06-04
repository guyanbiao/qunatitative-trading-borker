
class ClosePositionService
  attr_reader :order_execution_id, :client_order_id, :exchange, :user

  def initialize(user, client_order_id, exchange, order_execution_id: nil)
    @user = user
    @order_execution_id = order_execution_id
    @client_order_id = client_order_id
    @exchange = exchange
  end


  def execute
    opposite_direction = remote_order.direction == 'buy'  ? 'sell' : 'buy'

    result = exchange.place_order(
      client_order_id: client_order_id,
      volume: remote_order.volume,
      direction: opposite_direction,
      offset: 'close',
      lever_rate: remote_order.lever_rate
      )
    if result.success?
      ActiveRecord::Base.transaction do
        create_order!(
          remote_order_id: result.order_id,
          direction: opposite_direction,
          parent_order_id: remote_order.id,
          offset: 'close',
          volume: remote_order.volume,
          lever_rate: remote_order.lever_rate
        )
        yield if block_given?
      end
    end
    result
  end

  def create_order!(remote_order_id:, direction:, offset:, volume:, lever_rate:, parent_order_id: nil)
    UsdtStandardOrder.create!(
      volume: volume,
      client_order_id: client_order_id,
      remote_order_id: remote_order_id,
      order_execution_id: order_execution_id,
      contract_code: remote_order.contract_code,
      direction: direction,
      offset: offset,
      lever_rate: lever_rate,
      order_price_type: remote_order.order_price_type,
      parent_order_id: parent_order_id,
      user_id: remote_order.user_id
    )
  end

  def order_price_type
    'opponent'
  end

  def remote_order
    @remote_order ||= begin
      ro = exchange.current_position
      RemoteUsdtStandardOrder.new(
        id: nil,
        user_id: user.id,
        contract_code: exchange.contract_code,
        lever_rate: ro.lever_rate,
        volume: ro.volume,
        direction: ro.direction
      )
    end
  end
end