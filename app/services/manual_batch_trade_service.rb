class ManualBatchTradeService
  def create(trader:, user_ids:, currency:, action:, direction:)
    batch_execution = if action == 'open_position'
      ManualBatchExecution.create(
        action: action,
        trader_id: trader.id,
        user_ids: user_ids,
        action_params: {
          direction: direction, currency: currency
        })
    elsif action == 'close_position'
      ManualBatchExecution.create(
        action: action,
        trader_id: trader.id,
        user_ids: user_ids,
        action_params: {
          currency: currency
        })
    end
    execute(batch_execution)
    batch_execution
  end

  def execute(batch_execution)
    case batch_execution.action
    when 'open_position'
      open_position(batch_execution)
    when 'close_position'
      close_position(batch_execution)
    end
  end

  private
  def open_position(batch_execution)
    batch_execution.users.each do |user|
      currency = batch_execution.action_params['currency']
      direction = batch_execution.action_params['direction']
      exchange = user.exchange_class.new(user, currency)
      order_execution = OrderExecution.create!(
        trader_id: batch_execution.trader_id,
        user_id: user.id,
        currency: currency,
        direction: direction,
        exchange_id: exchange.id,
        batch_execution_id: batch_execution.id,
        action: 'open_position'
      )
      PlaceOrderJob.perform_async(order_execution.id)
    end
  end

  def close_position(batch_execution)
    batch_execution.users.each do |user|
      currency = batch_execution.action_params['currency'].upcase
      exchange = user.exchange_class.new(user, currency)
      order_execution = OrderExecution.create!(
        trader_id: batch_execution.trader_id,
        user_id: user.id,
        currency: currency,
        exchange_id: exchange.id,
        batch_execution_id: batch_execution.id,
        action: 'close_position'
      )
      ClosePositionJob.perform_async(order_execution.id, user.id)
    end
  end
end