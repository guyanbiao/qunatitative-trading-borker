class PlaceOrderJob
  include Sidekiq::Worker

  def perform(order_execution_id)
    order_execution = OrderExecution.find(order_execution_id)
    PlaceOrderService.new(order_execution.user, order_execution).execute
  end
end