class AddTraderIdToOrderExecutions < ActiveRecord::Migration[6.1]
  def change
    add_column :order_executions, :trader_id, :bigint, index: true
    add_column :order_execution_logs, :trader_id, :bigint, index: true
  end
end
