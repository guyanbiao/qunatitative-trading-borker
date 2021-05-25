class AddLeverRateToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :lever_rate, :integer
  end
end
