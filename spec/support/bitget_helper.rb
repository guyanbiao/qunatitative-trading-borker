# frozen_string_literal: true

module BitgetHelper
  def host
    @host ||= Rails.application.config_for(:bitget)[:host]
  end

  def stub_bitget_accounts
    r = Regexp.new(
      "#{host}/api/swap/v3/account/accounts"
    )
    stub_request(:get, r).to_return(
      status: 200,
      body: file_fixture('bitget/account_accounts.json'),
      headers: {}
    )
  end

  def stub_bitget_place_order
    r = Regexp.new(
      "#{host}/api/swap/v3/order/placeOrder"
    )
    stub_request(:post, r).to_return(
      status: 200,
      body: file_fixture('bitget/order_place_order.json'),
      headers: {}
    )
  end

  def stub_bitget_order_info
    r = Regexp.new(
      "#{host}/api/swap/v3/order/detail\\?.*"
    )
    stub_request(:get, r).to_return(
      status: 200,
      body: file_fixture('bitget/order_detail.json'),
      headers: {}
    )
  end

  def stub_bitget_current_position
    r = Regexp.new(
      "#{host}/api/swap/v3/position/singlePosition\\?.*"
    )
    stub_request(:get, r).to_return(
      status: 200,
      body: file_fixture('bitget/position_single_position.json'),
      headers: {}
    )
  end

  def stub_bitget_history
    r = Regexp.new(
      "#{host}/api/swap/v3/order/history\\?.*"
    )
    stub_request(:get, r).to_return(
      status: 200,
      body: file_fixture('bitget/order_history.json'),
      headers: {}
    )
  end

  def stub_bitget_history_first_100
    stub_request(:get, "https://bitget.test.com/api/swap/v3/order/history").
      with(query: {createDate: 90, pageIndex: 1, pageSize: 100, symbol: 'cmt_btcusdt'}).
      to_return(
      status: 200,
      body: file_fixture('bitget/order_history.json'),
      headers: {}
    )
  end

  def stub_bitget_history_second_100
    stub_request(:get, "https://bitget.test.com/api/swap/v3/order/history").
      with(query: {createDate: 90, pageIndex: 2, pageSize: 100, symbol: 'cmt_btcusdt'}).
      to_return(
        status: 200,
        body: [].to_json,
        headers: {}
      )
  end

  def stub_bitget_current_price
    r = Regexp.new(
      "#{host}/api/swap/v3/market/ticker\\?.*"
    )
    stub_request(:get, r).to_return(
      status: 200,
      body: file_fixture('bitget/market_ticker.json'),
      headers: {}
    )
  end

  def stub_bitget_contract_size
    r = Regexp.new(
      "#{host}/api/swap/v3/market/contracts"
    )
    stub_request(:get, r).to_return(
      status: 200,
      body: file_fixture('bitget/market_contracts.json'),
      headers: {}
    )
  end
end

RSpec.configure { |config| config.include BitgetHelper }