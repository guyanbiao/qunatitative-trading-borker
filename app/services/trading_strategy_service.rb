class TradingStrategyService
  MAX_CONSECUTIVE_FAIL_TIMES = 5
  DEFAULT_STRATEGY = 'constant'
  DEFAULT_PERCENTAGE = 0.005.to_d
  attr_reader :trader, :exchange
  def initialize(trader:, exchange:)
    @trader = trader
    @exchange = exchange
  end

  def open_order_percentage
    @open_order_percentage ||= begin
      if strategy_config.name == 'constant'
        default_percentage
      elsif strategy_config.name == 'tier'
        tier_percentage
      end
    end
  end

  private
  def tier_percentage
    return default_percentage unless exchange.has_history?
    return default_percentage if exchange.last_order_profit?

    (consecutive_fail_times + 1) *  default_percentage
  end

  def max_consecutive_fail_times
    @max_consecutive_fail_times ||= strategy_config.max_consecutive_fail_times
  end

  def strategy_config
    @strategy_config ||= TradingStrategy.find_by(trader_id: trader.id) || default_trading_strategy
  end

  def default_trading_strategy
    @default_trading_strategy ||= TradingStrategy.new(
      trader_id: trader.id,
      name: Setting.default_trading_strategy,
      max_consecutive_fail_times: Setting.max_consecutive_fail_times
    )
  end

  def default_percentage
    @default_percentage ||= exchange.user.first_order_percentage || DEFAULT_PERCENTAGE
  end

  def consecutive_fail_times
    @consecutive_fail_times ||= exchange.continuous_fail_times % max_consecutive_fail_times
  end
end