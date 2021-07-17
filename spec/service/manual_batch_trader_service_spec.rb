require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ManualBatchTradeService do
  let(:user) {
    User.create!(
      email: 'foo@bar.com',
      password: 'abcdabcd',
      huobi_access_key: 'oo',
      huobi_secret_key: 'ooo',
      trader_id: trader.id,
    )
  }

  let(:trader) {
    Trader.create!(webhook_token: 'oo', email: 'a@b.com', password: 'oooppp')
  }

  let(:currency) { 'BTC' }

  let(:exchange) { Exchange::Huobi.new(user, currency) }

  let(:service) {ManualBatchTradeService.new}

  before :each do
    Sidekiq::Testing.inline!
    stub_user_current_position
    stub_order_info
    stub_place_order
    stub_user_history
    stub_price_limit
    stub_contract_info
    stub_contract_balance
    stub_user_history
  end

  it 'should open position' do
    batch_execution = service.create(trader: trader, user_ids: [user.id], currency: currency, action: 'open_position', direction: 'buy')
    order_execution = OrderExecution.last
    expect(order_execution.currency).to eq('BTC')
    expect(order_execution.direction).to eq('buy')
    expect(order_execution.batch_execution_id).to eq(batch_execution.id)
  end

  it 'should close position' do
    stub_user_current_position
    batch_execution = service.create(trader: trader, user_ids: [user.id], currency: currency, action: 'close_position', direction: nil)
    order_execution = OrderExecution.last
    expect(order_execution.currency).to eq('BTC')
    expect(order_execution.batch_execution_id).to eq(batch_execution.id)
    expect(UsdtStandardOrder.last.status).to eq('done')
  end
end