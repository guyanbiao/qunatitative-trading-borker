require 'rails_helper'

RSpec.describe Exchange::Bitget do
  let(:user) {
    User.create!(
      email: 'foo@bar.com',
      password: 'abcdabcd',
      bitget_access_key: 'oo',
      bitget_secret_key: 'ooo'
    )
  }
  subject(:exchange) {Exchange::Bitget.new(user, 'ETH')}

  it 'balance' do
    stub_bitget_accounts
    expect(exchange.balance).to eq(90.to_d)
  end

  it 'place_order' do
    stub_bitget_place_order

    result = exchange.place_order(
      client_order_id: '223',
      volume: 1,
      direction: 'buy',
      offset: 'open',
      lever_rate: nil
    )

    expect(result.order_id).to eq('513466539039522813')
  end

  it '.order_info' do
    stub_bitget_order_info

    result = exchange.order_info('sss')

    expect(result.order_placed?).to eq(true)
    expect(result.profit).to eq('30'.to_d)
    expect(result.real_profit).to eq('30'.to_d)
    expect(result.trade_avg_price).to eq('2869.32'.to_d)
    expect(result.fee).to eq('-0.1721592'.to_d)
    expect(result.status).to eq('2')
    expect(result.price).to eq(0.to_d)
  end

  it '.current_position' do
    stub_bitget_current_position

    result = exchange.current_position

    expect(result.lever_rate).to eq(20)
    expect(result.volume).to eq(1)
    expect(result.direction).to eq('buy')
    expect(result.has_position?).to eq(true)
    expect(result.currency).to eq('ETH')
  end

  it '.has_position' do
    stub_bitget_current_position

    expect(exchange.has_position?).to eq(true)
  end

  it '.continuous_fail_times?' do
    stub_bitget_history

    expect(exchange.continuous_fail_times).to eq(0)
  end

  it '.has_history?' do
    stub_bitget_history

    expect(exchange.has_history?).to eq(true)
  end

  it '.last_order_profit?' do
    stub_bitget_history

    expect(exchange.last_order_profit?).to eq(true)
  end

  it '.current_price' do
    stub_bitget_current_price

    expect(exchange.current_price).to eq('2804.35'.to_d)
  end

  it '.contract_size' do
    stub_bitget_contract_size

    expect(exchange.contract_size).to eq('0.1'.to_d)
  end
end
