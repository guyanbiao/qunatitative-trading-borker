# frozen_string_literal: true

module HuobiHelper
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

  def stub_contract_balance
    r = Regexp.new( "https://huobi.test.com/linear-swap-api/v1/swap_balance_valuation\\?.*" )
    stub_request(:post, r).to_return(
      status: 200,
      body: file_fixture('swap_contract_balance.json'),
      headers: {}
    )
  end
end

RSpec.configure { |config| config.include HuobiHelper }
