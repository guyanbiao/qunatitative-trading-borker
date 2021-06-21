class CreateHistoryOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :history_orders do |t|
      t.string :symbol
      t.decimal :profit
      t.string :exchange
      t.string :currency
      t.bigint :volume
      t.datetime :order_placed_at, index: true
      t.decimal :fees
      t.string :remote_order_id, index: {unique: true}
      t.decimal :trade_avg_price
      t.bigint :user_id, index: true

      t.timestamps
    end
    add_index :history_orders, [:user_id, :order_placed_at]
  end
end