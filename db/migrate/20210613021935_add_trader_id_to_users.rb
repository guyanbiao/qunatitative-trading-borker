class AddTraderIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :trader_id, :bigint, index: true
  end
end
