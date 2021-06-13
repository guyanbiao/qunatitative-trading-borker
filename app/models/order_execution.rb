class OrderExecution < ApplicationRecord
  include AASM
  validates_presence_of :user_id, :exchange_id
  scope :unfinished, -> {where.not(status: 'open_order_confirmed')}

  belongs_to :user
  belongs_to :trader

  aasm column: :status do
    state :created, initial: true
    state :new_order # no open order exist
    state :close_order_placed
    state :close_order_finished
    state :open_order_placed
    state :open_order_confirmed

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

    event :open_confirm do
      transitions from: :open_order_placed, to: :open_order_confirmed
    end
  end

  def logs
    OrderExecutionLog.where(order_execution_id: id)
  end
end
