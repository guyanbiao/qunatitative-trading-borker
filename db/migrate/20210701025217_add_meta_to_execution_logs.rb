class AddMetaToExecutionLogs < ActiveRecord::Migration[6.1]
  def change
    add_column :order_execution_logs, :meta, :jsonb
  end
end
