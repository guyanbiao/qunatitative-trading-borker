class AddReceivingAlertsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :receiving_alerts, :boolean, default: true
  end
end
