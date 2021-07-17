class ClosePositionJob
  include Sidekiq::Worker

  def perform(order_execution_id, user_id)
    order_execution = OrderExecution.find(order_execution_id)
    user = User.find(user_id)
    PlaceOrderService.new(user, order_execution).close_position(get_client_order_id)
  end

  def get_client_order_id
    rand(9223372036854775807)
  end
end