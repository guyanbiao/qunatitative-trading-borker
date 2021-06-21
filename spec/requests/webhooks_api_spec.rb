require 'sidekiq/testing'
require 'rails_helper'

RSpec.describe WebhooksController do
  let(:token) {'adjkladsjfkajsdfsfd'}
  it 'works' do
    Sidekiq::Testing.inline!
    @trader = Trader.create!(
      webhook_token: token, email: 'a@b.com', password: 'oooppp'
    )
    @user = User.create!(
      email: 'foo@bar.com',
      password: 'abcdabcd',
      huobi_access_key: 'oo',
      huobi_secret_key: 'ooo',
      trader_id: @trader.id
    )
    allow_any_instance_of(WebhookHandlingService).to receive(:valid_ips).and_return(['127.0.0.1'])
    ActionController::Base.allow_forgery_protection = true
    stub_price_limit
    stub_place_order
    stub_order_info
    stub_contract_info
    stub_contract_balance
    stub_user_no_current_position
    stub_user_history
    post "/webhooks/alert/#{token}",
         params: {
           direction: 'buy',
           ticker: 'BTCUSDT'
         }.to_json,
         headers:
           {
             'Content-Type': 'application/json'
           }
    expect(response.status).to eq(200)
    expect(response.body).to eq('success')
    # order
    expect(UsdtStandardOrder.count).to eq(1)
    order = UsdtStandardOrder.last
    expect(order.direction).to eq('buy')
    expect(order.remote_status).to eq(6)
    expect(order.remote_order_id).to eq(845810451073155072)
    # order execution
    order_execution = OrderExecution.last
    expect(order_execution.status).to eq('open_order_confirmed')
    alert_log = AlertLog.last
    expect(alert_log.ip_address).to eq('127.0.0.1')
    expect(alert_log.source_type).to eq('trader')
    expect(alert_log.source_id).to eq(@trader.id)
    expect(alert_log.error_code).to eq(nil)
    expect(alert_log.error_message).to eq(nil)
    expect(alert_log.status).to eq('ok')
    expect(alert_log.content).to eq("{\"token\":\"adjkladsjfkajsdfsfd\",\"direction\":\"buy\",\"ticker\":\"BTCUSDT\"}")
  end

  it 'return invalid ip address' do
    in_correct_ticker = 'BTCUSDTO'
    post "/webhooks/alert/#{token}",
         params: {
           direction: 'buy',
           ticker: in_correct_ticker
         }.to_json,
         headers:
           {
             'Content-Type': 'application/json'
           }
    expect(response.body).to eq('001')
    alert_log = AlertLog.last
    expect(alert_log.ip_address).to eq('127.0.0.1')
    expect(alert_log.status).to eq('error')
  end
end