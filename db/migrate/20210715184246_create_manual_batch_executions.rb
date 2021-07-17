class CreateManualBatchExecutions < ActiveRecord::Migration[6.1]
  def change
    create_table :manual_batch_executions do |t|
      t.string :action
      t.bigint :trader_id
      t.jsonb :action_params
      t.bigint :user_ids, array: true

      t.timestamps
    end
  end
end
