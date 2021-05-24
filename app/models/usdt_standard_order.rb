class UsdtStandardOrder < ApplicationRecord
  module RemoteStatus
    # (1准备提交 2准备提交 3已提交 4部分成交 5部分成交已撤单 6全部成交 7已撤单 11撤单中)
    PLACED = 3
    FINISHED = 6
  end

  validates_presence_of :user_id

  include AASM
  aasm column: :status do
    state :processing, initial: true
    state :done

    event :finish do
      transitions from: :processing, to: :done
    end
  end

  scope :open, -> {where(offset: 'open')}
  scope :close, -> {where(offset: 'close')}

  def profit?
    real_profit > 0
  end

  def parent_order
    UsdtStandardOrder.find(parent_order_id)
  end
end
