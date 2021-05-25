require 'rails_helper'

RSpec.describe PlaceOrderService do
  before :each do
    stub_price_limit
    stub_place_order
    stub_order_info
    stub_contract_info
    @user = User.create!(
      email: 'foo@bar.com',
      password: 'abcdabcd',
      huobi_access_key: 'oo',
      huobi_secret_key: 'ooo'
    )
  end

  it 'open first order' do
    order_execution = OrderExecution.create!(
      currency: 'BTC',
      direction: 'buy',
      user_id: @user.id
    )

    PlaceOrderService.new(@user, order_execution).execute

    # order
    expect(UsdtStandardOrder.count).to eq(1)
    order = UsdtStandardOrder.last
    expect(order.direction).to eq('buy')
    expect(order.remote_status).to eq(6)
    expect(order.remote_order_id).to eq(845810451073155072)
    # order execution
    order_execution = OrderExecution.last
    expect(order_execution.status).to eq('open_order_confirmed')
  end

  it 'has open order' do
    expect(PlaceOrderService::DEFAULT_PERCENTAGE).to eq(0.005.to_d)
    first_order = UsdtStandardOrder.create!(
      volume: 3,
      client_order_id: 3323,
      remote_order_id: 232332,
      order_execution_id: nil,
      contract_code: 'BTC-USDT',
      direction: 'buy',
      offset: 'open',
      lever_rate: 5,
      order_price_type: 'opponent',
      open_price: 10,
      close_price: 20,
      user_id: @user.id
    )

    order_execution = OrderExecution.create!(
      currency: 'BTC',
      direction: 'sell',
      user_id: @user.id
    )

    PlaceOrderService.new(@user, order_execution).execute

    # exist order
    first_order.reload
    expect(first_order.offset).to eq('open')
    expect(first_order.direction).to eq('buy')
    expect(first_order.status).to eq('done')
    expect(first_order.remote_status).to eq(6)
    expect(first_order.profit).to eq(-0.3854.to_d)
    # close exist order
    second_order = UsdtStandardOrder.all.order(:id)[1]
    expect(second_order.offset).to eq('close')
    expect(second_order.direction).to eq('sell')
    expect(second_order.parent_order_id).to eq(1)
    expect(second_order.remote_status).to eq(6)
    expect(second_order.profit).to eq(-0.3854.to_d)
    # place new order
    last_order = UsdtStandardOrder.all.order(:id)[2]
    expect(last_order.parent_order_id).to eq(nil)
    expect(last_order.remote_status).to eq(6)
    expect(last_order.offset).to eq('open')
    expect(last_order.direction).to eq('sell')
  end

  context :percentage do
    it 'works' do
      UsdtStandardOrder.create!(
        volume: 3,
        client_order_id: 3323,
        remote_order_id: 232332,
        order_execution_id: nil,
        contract_code: 'BTC-USDT',
        direction: 'buy',
        offset: 'open',
        lever_rate: 5,
        order_price_type: 'opponent',
        open_price: 10,
        close_price: 20,
        real_profit: -3,
        user_id: @user.id
      )
      UsdtStandardOrder.create(
        volume: 3,
        client_order_id: 33231,
        remote_order_id: 232332,
        order_execution_id: nil,
        contract_code: 'BTC-USDT',
        direction: 'sell',
        offset: 'open',
        lever_rate: 5,
        order_price_type: 'opponent',
        open_price: 10,
        close_price: 20,
        real_profit: 3,
        user_id: @user.id
      )
      UsdtStandardOrder.create(
        volume: 3,
        client_order_id: 332323,
        remote_order_id: 232332,
        order_execution_id: nil,
        contract_code: 'BTC-USDT',
        direction: 'sell',
        offset: 'open',
        lever_rate: 5,
        order_price_type: 'opponent',
        open_price: 10,
        close_price: 20,
        real_profit: -3,
        user_id: @user.id
      )

      order_execution = OrderExecution.create!(
        currency: 'BTC',
        direction: 'buy',
        user_id: @user.id
      )
      service = PlaceOrderService.new(@user, order_execution)
      expect(service.send(:continuous_fail_times)).to eq(1)
      expect(service.send(:percentage)).to eq(0.01.to_d)
    end
  end

  def stub_price_limit
    r = Regexp.new(
      "https://huobi.test.com/linear-swap-api/v1/swap_price_limit?.*"
    )
    stub_request(:get, r).to_return(
      status: 200,
      body: file_fixture('swap_price_limit.json'),
      headers: {}
    )
  end

  def stub_place_order
    r = Regexp.new( "https://huobi.test.com/linear-swap-api/v1/swap_cross_order\\?.*" )
    stub_request(:post, r).to_return(
      status: 200,
      body: file_fixture('swap_cross_order.json'),
      headers: {}
    )
  end

  def stub_order_info
    r = Regexp.new( "https://huobi.test.com/linear-swap-api/v1/swap_cross_order_info\\?.*" )
    stub_request(:post, r).to_return(
      status: 200,
      body: file_fixture('swap_cross_order_info.json'),
      headers: {}
    )
  end

  def stub_contract_info
    r = Regexp.new( "https://huobi.test.com/linear-swap-api/v1/swap_contract_info\\?.*" )
    stub_request(:get, r).to_return(
      status: 200,
      body: file_fixture('swap_contract_info.json'),
      headers: {}
    )
  end
end
