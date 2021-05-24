class CreateUsdtStandardOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :usdt_standard_orders do |t|
      t.string :contract_code
      t.bigint :remote_order_id, index: true            # houbi order id
      t.bigint :client_order_id, index: {unique: true}  # system order id
      t.bigint :user_id, index: true
      t.decimal :open_price
      t.decimal :close_price
      t.bigint :volume
      t.string :direction
      t.string :offset
      t.string :order_price_type
      t.string :status
      t.integer :remote_status
      t.bigint :parent_order_id
      t.bigint :order_execution_id
      t.bigint :lever_rate
      t.decimal :profit
      t.decimal :real_profit
      t.decimal :trade_avg_price
      t.decimal :fee

      t.timestamps
    end
  end
end
