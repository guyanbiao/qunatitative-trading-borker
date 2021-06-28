class TradingStrategy < ApplicationRecord
  extend Enumerize

  enumerize :name, in: [:constant, :tier]

  belongs_to :trader

  validates_presence_of :name, :max_consecutive_fail_times
end
