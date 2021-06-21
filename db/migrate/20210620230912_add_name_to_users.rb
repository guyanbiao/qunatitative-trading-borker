class AddNameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :name, :string, index: {unique: true}
    add_column :users, :phone_number, :string, index: {unique: true}
  end
end