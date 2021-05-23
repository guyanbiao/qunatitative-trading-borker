class CreateOrderExecutionLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :order_execution_logs do |t|
      t.bigint :order_execution_id
      t.string :action
      t.string :response

      t.timestamps
    end
  end
end
