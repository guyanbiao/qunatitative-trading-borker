class AddActionToOrderExections < ActiveRecord::Migration[6.1]
  def change
    add_column :order_executions, :action, :string
  end
end
