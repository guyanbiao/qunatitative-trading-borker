require 'rails_helper'

RSpec.describe PlaceOrderService do
  before :each do
    stub_price_limit
    stub_place_order
    stub_order_info
    stub_contract_info
    stub_contract_balance
    stub_user_current_position
    stub_user_history
    @trader = Trader.create!(webhook_token: 'oo', email: 'a@b.com', password: 'oooppp')
    @user = User.create!(
      email: 'foo@bar.com',
      password: 'abcdabcd',
      huobi_access_key: 'oo',
      huobi_secret_key: 'ooo',
      trader_id: @trader.id
    )
  end

  context '.lever_rate' do
    it 'works' do
      order_execution = OrderExecution.create!(
        currency: 'BTC',
        direction: 'buy',
        user_id: @user.id,
        exchange_id: 'huobi',
        trader_id: @trader.id,
        action: 'open_position'
      )
      exchange = Exchange::Huobi.new(@user, 'BTC')
      service = PlaceOrderService.new(@user, order_execution)
      expect(service.lever_rate).to eq(100)
      expect(service.balance).to eq('68.839155724155396568'.to_d)
      expect(service.open_position_service.open_order_percentage).to eq('0.005'.to_d)
      expect(service.open_position_service.contract_price).to eq('38.5672'.to_d)
      expect(service.open_position_service.calculate_open_position_volume).to eq(1)
    end
  end

  it 'no position' do
    stub_user_no_current_position
    order_execution = OrderExecution.create!(
      currency: 'BTC',
      direction: 'buy',
      user_id: @user.id,
      exchange_id: 'huobi',
      trader_id: @trader.id,
      action: 'open_position'
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
    expect(order_execution.status).to eq('done')
    log = OrderExecutionLog.find_by(action: 'open_position')
    expect(log.meta).to eq({"balance"=>"68.839155724155396568", "lever_rate"=>100, "contract_price"=>"38.5672", "open_order_percentage"=>"0.005"})
  end

  it 'works' do
    order_execution = OrderExecution.create!(
      currency: 'BTC',
      direction: 'buy',
      user_id: @user.id,
      exchange_id: 'huobi',
      trader_id: @trader.id,
      action: 'open_position'
    )

    PlaceOrderService.new(@user, order_execution).execute
    
    log = OrderExecutionLog.last
    expect(log.action).to eq('skip_execution_same_direction')
  end

  it 'has open order' do
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
      user_id: @user.id,
      exchange_id: 'huobi'
    )

    order_execution = OrderExecution.create!(
      currency: 'BTC',
      direction: 'sell',
      user_id: @user.id,
      exchange_id: 'huobi',
      trader_id: @trader.id,
      action: 'open_position'
    )

    exchange = Exchange::Huobi.new(@user, 'BTC')
    PlaceOrderService.new(@user, order_execution).execute

    # update exist open order
    first_order.reload
    expect(first_order.offset).to eq('open')
    expect(first_order.direction).to eq('buy')
    # close exist order
    second_order = UsdtStandardOrder.all.order(:id)[1]
    expect(second_order.offset).to eq('close')
    expect(second_order.direction).to eq('sell')
    expect(second_order.remote_status).to eq(6)
    expect(second_order.profit).to eq(-0.3854.to_d)
    expect(second_order.order_execution_id).to eq(order_execution.id)
    # place new order
    last_order = UsdtStandardOrder.all.order(:id)[2]
    expect(last_order.parent_order_id).to eq(nil)
    expect(last_order.remote_status).to eq(6)
    expect(last_order.offset).to eq('open')
    expect(last_order.direction).to eq('sell')
  end

  context 'open_order_percentage' do
    it 'works' do
      UsdtStandardOrder.create!(
        volume: 3,
        client_order_id: 3323,
        remote_order_id: 232332,
        order_execution_id: nil,
        contract_code: 'BTC-USDT',
        direction: 'buy',
        offset: 'close',
        lever_rate: 5,
        order_price_type: 'opponent',
        open_price: 10,
        close_price: 20,
        real_profit: -3,
        user_id: @user.id,
        status: 'done',
        exchange_id: 'huobi'
      )
      UsdtStandardOrder.create(
        volume: 3,
        client_order_id: 33231,
        remote_order_id: 232332,
        order_execution_id: nil,
        contract_code: 'BTC-USDT',
        direction: 'sell',
        offset: 'close',
        lever_rate: 5,
        order_price_type: 'opponent',
        open_price: 10,
        close_price: 20,
        real_profit: 3,
        user_id: @user.id,
        status: 'done',
        exchange_id: 'huobi'
      )
      UsdtStandardOrder.create(
        volume: 3,
        client_order_id: 332323,
        remote_order_id: 232332,
        order_execution_id: nil,
        contract_code: 'BTC-USDT',
        direction: 'sell',
        offset: 'close',
        lever_rate: 5,
        order_price_type: 'opponent',
        open_price: 10,
        close_price: 20,
        real_profit: -3,
        user_id: @user.id,
        status: 'done',
        exchange_id: 'huobi'
      )
      order_execution = OrderExecution.create!(
        currency: 'BTC',
        direction: 'buy',
        user_id: @user.id,
        exchange_id: 'huobi',
        trader_id: @trader.id,
        action: 'open_position'
      )
      service = PlaceOrderService.new(@user, order_execution)
      expect(service.open_position_service.send(:open_order_percentage)).to eq(0.005.to_d)
    end
  end
end
