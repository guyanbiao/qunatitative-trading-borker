class CreateTradingStrategies < ActiveRecord::Migration[6.1]
  def change
    create_table :trading_strategies do |t|
      t.bigint :trader_id
      t.string :name
      t.integer :max_consecutive_fail_times
      t.timestamps
    end
  end
end
