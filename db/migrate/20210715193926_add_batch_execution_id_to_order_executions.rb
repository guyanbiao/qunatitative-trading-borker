class AddBatchExecutionIdToOrderExecutions < ActiveRecord::Migration[6.1]
  def change
    add_column :order_executions, :batch_execution_id, :bigint, index: true
  end
end
