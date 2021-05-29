class CreateAlertLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :alert_logs do |t|
      t.timestamps
      t.text :content
      t.text :source_type
      t.bigint :source_id
      t.string :ip_address
      t.string :error_code
      t.string :error_message
      t.string :status
    end
  end
end