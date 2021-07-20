class AddWxOpenIdToTraders < ActiveRecord::Migration[6.1]
  def change
    add_column :traders, :wx_open_id, :string, index: true
  end
end