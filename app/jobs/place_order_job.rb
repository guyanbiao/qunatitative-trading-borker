class PlaceOrderJob
  include Sidekiq::Worker

  def perform(order_execution_id)
    order_execution = OrderExecution.find(order_execution_id)
    if Time.now - order_execution.created_at > OrderExecution::MAX_VALID_TIME
      return
    end

    10.times do
      PlaceOrderService.new(order_execution.user, order_execution).execute
      break if order_execution.reload.status == 'done'

      sleep 0.5
    end
  end
end