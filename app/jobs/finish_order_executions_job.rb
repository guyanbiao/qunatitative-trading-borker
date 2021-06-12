class FinishOrderExecutionsJob
  MAX_VALID_TIME = 5.minutes
  include Sidekiq::Worker

  def perform
    executions.each do |order_execution|
      PlaceOrderService.new(order_execution.user, order_execution).execute
    end
  end

  private
  def executions
    OrderExecution.where("created_at > ?", MAX_VALID_TIME.ago).unfinished
  end
end