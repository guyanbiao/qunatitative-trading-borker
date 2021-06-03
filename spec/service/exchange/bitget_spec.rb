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
end
