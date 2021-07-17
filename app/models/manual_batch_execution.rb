class ManualBatchExecution < ApplicationRecord
  extend Enumerize
  belongs_to :trader
  has_many :order_executions, foreign_key: :batch_execution_id
  enumerize :action, in: [:open_position, :close_position]

  def users
    trader.users.enable.where(id: user_ids)
  end
end
