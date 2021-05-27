class AddWebhookTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :webhook_token, :string
  end
end
