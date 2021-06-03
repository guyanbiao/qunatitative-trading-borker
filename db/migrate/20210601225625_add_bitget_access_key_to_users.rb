class AddBitgetAccessKeyToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :bitget_access_key, :string
    add_column :users, :bitget_secret_key, :string
    add_column :users, :bitget_pass_phrase, :string
  end
end
