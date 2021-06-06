class AddExchangeToUsdtStandardOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :usdt_standard_orders, :exchange_id, :string
    add_column :order_executions, :exchange_id, :string
  end
end
