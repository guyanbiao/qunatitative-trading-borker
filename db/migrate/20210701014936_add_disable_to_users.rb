class AddDisableToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :enable, :boolean, default: true
  end
end
