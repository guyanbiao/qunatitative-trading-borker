class AddIgnoredToAlertLogs < ActiveRecord::Migration[6.1]
  def change
    add_column :alert_logs, :ignored, :boolean
  end
end
