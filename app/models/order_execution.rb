class OrderExecution < ApplicationRecord
  MAX_VALID_TIME = 5.minutes

  extend Enumerize
  include AASM
  validates_presence_of :user_id, :exchange_id, :action
  scope :unfinished, -> {where.not(status: 'done')}

  belongs_to :user
  belongs_to :trader
  enumerize :action, in: [:open_position, :close_position]

  aasm column: :status do
    state :created, initial: true
    state :new_order # no open order exist
    state :close_order_placed
    state :close_order_finished
    state :open_order_placed
    state :done

    event :close do
      transitions from: :created, to: :close_order_placed
    end

    event :open_new_order do
      transitions from: :created, to: :new_order
    end

    event :close_finish do
      transitions from: :close_order_placed, to: :close_order_finished
    end

    event :open_order do
      transitions from: [:new_order, :close_order_finished], to: :open_order_placed
    end

    event :finish do
      transitions from: [:new_order, :open_order_placed, :close_order_placed], to: :done
      after do
        WeixinNotificationJob.perform_async(self.id)
      end
    end
  end

  def logs
    OrderExecutionLog.where(order_execution_id: id)
  end
end
