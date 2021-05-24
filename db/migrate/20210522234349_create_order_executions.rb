class CreateOrderExecutions < ActiveRecord::Migration[6.1]
  def change
    create_table :order_executions do |t|
      t.bigint :user_id, index: true
      t.string :status
      t.string :currency
      t.string :direction

      t.timestamps
    end
  end
end
