require 'rails_helper'

RSpec.describe TradingStrategyService do
  let(:user) {
    User.create!(
      email: 'foo@bar.com',
      password: 'abcdabcd',
      huobi_access_key: 'oo',
      huobi_secret_key: 'ooo',
      trader_id: trader.id
    )
  }

  let(:trader) {
    Trader.create!(webhook_token: 'oo', email: 'a@b.com', password: 'oooppp')
  }

  let(:exchange) { Exchange::Huobi.new(user, 'ETH') }

  subject (:service) {
     TradingStrategyService.new(trader: trader, exchange: exchange)
  }

  context 'tier strategy' do
    it 'works' do
      stub_user_history_with_loss
      strategy_config = service.send(:strategy_config)
      expect(strategy_config.name).to eq('tier')
      expect(exchange.has_history?).to eq(true)
      expect(exchange.last_order_profit?).to eq(false)
      expect(exchange.continuous_fail_times).to eq(4)
      expect(service.send(:open_order_percentage)).to eq(0.005.to_d * 5)
    end

    it 'last order has profit' do
      stub_user_history
      strategy_config = service.send(:strategy_config)
      expect(strategy_config.name).to eq('tier')
      expect(exchange.has_history?).to eq(true)
      expect(exchange.last_order_profit?).to eq(true)
      expect(service.send(:open_order_percentage)).to eq(0.005.to_d)
    end

    it 'reset to default' do
      stub_user_history_with_loss
      TradingStrategy.create!(trader_id: trader.id, name: 'tier', max_consecutive_fail_times: 4)
      strategy_config = service.send(:strategy_config)
      expect(strategy_config.name).to eq('tier')
      expect(exchange.has_history?).to eq(true)
      expect(exchange.last_order_profit?).to eq(false)
      expect(exchange.continuous_fail_times).to eq(4)
      expect(service.send(:open_order_percentage)).to eq(0.005.to_d)
    end
  end

  context 'constant strategy' do
    it 'reset to default' do
      stub_user_history_with_loss
      TradingStrategy.create!(trader_id: trader.id, name: 'constant', max_consecutive_fail_times: 3)
      strategy_config = service.send(:strategy_config)
      expect(strategy_config.name).to eq('constant')
      expect(service.send(:open_order_percentage)).to eq(0.005.to_d)
    end
  end
end
