require 'rails_helper'

RSpec.describe UsdtStandardOrdersController, type: :request do
  before(:each) do
    @user = User.create!(
      email: 'foo@bar.com',
      password: 'abcdabcd',
      huobi_access_key: 'oo',
      huobi_secret_key: 'ooo'
    )
  end

  it 'works' do
    stub_user_current_position
    order = UsdtStandardOrder.create!(
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

    stub_place_order

    post "/usdt_standard_orders/close_position?currency=BTC",
         params: {
           action: 'test'
         }.to_json

    expect(response.status).to eq(302)
  end
end
