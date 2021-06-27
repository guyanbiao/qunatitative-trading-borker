require 'sidekiq/testing'
require 'rails_helper'

RSpec.describe SyncHistoryOrderJob do
  let!(:user) {
    User.create!(
      email: 'foo@bar.com',
      password: 'abcdabcd',
      bitget_access_key: 'oo',
      bitget_secret_key: 'ooo',
      bitget_pass_phrase: '111'
    )
  }

  it 'works' do
    Sidekiq::Testing.inline!
    Setting.support_currencies = %w[BTC]
    stub_bitget_history_first_100
    stub_bitget_history_second_100
    SyncHistoryOrderJob.perform_async

    expect(HistoryOrder.count).to eq(2)
    first_order = HistoryOrder.first
    puts first_order.inspect
    expect(first_order.profit).to eq('3.593'.to_d)
    expect(first_order.exchange).to eq('bitget')
    expect(first_order.currency).to eq('BTC')
    expect(first_order.volume).to eq(1)
    expect(first_order.fees).to eq('-0.1692798'.to_d)
    expect(first_order.remote_order_id).to eq('784226200150081515')
    expect(first_order.trade_avg_price).to eq('2821.33'.to_d)
    expect(first_order.user_id).to eq(1)
  end
end