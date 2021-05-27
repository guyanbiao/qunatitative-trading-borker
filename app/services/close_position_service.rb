
class ClosePositionService
  # @param order UsdtStandardOrder
  attr_reader :order, :order_execution_id, :client_order_id

  def initialize(order, client_order_id, order_execution_id: nil)
    @order = order
    @order_execution_id = order_execution_id
    @client_order_id = client_order_id
  end

  def execute
    opposite_direction = order.direction == 'buy'  ? 'sell' : 'buy'
    result = client.contract_place_order(
      order_id: client_order_id,
      contract_code: order.contract_code,
      price: nil,
      volume: order.volume,
      direction: opposite_direction,
      offset: 'close',
      lever_rate: order.lever_rate,
      order_price_type: order.order_price_type,
      )
    if result['status'] == 'ok'
      ActiveRecord::Base.transaction do
        create_order!(
          remote_order_id: result['data']['order_id'],
          direction: opposite_direction,
          parent_order_id: order.id,
          offset: 'close',
          volume: order.volume,
          lever_rate: order.lever_rate
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
      contract_code: order.contract_code,
      direction: direction,
      offset: offset,
      lever_rate: lever_rate,
      order_price_type: order.order_price_type,
      parent_order_id: parent_order_id,
      user_id: order.user_id
    )
  end

  def client
    @client ||= HuobiClient.new(User.find(order.user_id))
  end
end