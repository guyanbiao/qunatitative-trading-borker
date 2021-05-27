
require 'rails_helper'

RSpec.describe WebhooksController do
  it 'works' do
    @user = User.create!(
      email: 'foo@bar.com',
      password: 'abcdabcd',
      huobi_access_key: 'oo',
      huobi_secret_key: 'ooo',
      webhook_token: 'abc'
    )
    allow_any_instance_of(WebhooksController).to receive(:valid_ips).and_return(['127.0.0.1'])
    ActionController::Base.allow_forgery_protection = true
    stub_price_limit
    stub_place_order
    stub_order_info
    stub_contract_info
    stub_contract_balance
    post '/webhooks/alert/abc',
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
  end
end