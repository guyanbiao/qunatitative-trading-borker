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

  def stub_user_current_position
    r = Regexp.new( "https://huobi.test.com/linear-swap-api/v1/swap_cross_position_info\\?.*" )
    stub_request(:post, r).to_return(
      status: 200,
      body: file_fixture('swap_cross_position_info.json'),
      headers: {}
    )
  end

  def stub_user_no_current_position
    r = Regexp.new( "https://huobi.test.com/linear-swap-api/v1/swap_cross_position_info\\?.*" )
    stub_request(:post, r).to_return(
      status: 200,
      body: file_fixture('no_swap_cross_position_info.json'),
      headers: {}
    )
  end

  def stub_user_history
    r = Regexp.new( "https://huobi.test.com/linear-swap-api/v1/swap_cross_matchresults\\?.*" )
    stub_request(:post, r).to_return(
      status: 200,
      body: file_fixture('swap_cross_matchresults.json'),
      headers: {}
    )
  end

  def stub_user_history_with_loss
    r = Regexp.new( "https://huobi.test.com/linear-swap-api/v1/swap_cross_matchresults\\?.*" )
    stub_request(:post, r).to_return(
      status: 200,
      body: file_fixture('swap_cross_matchresults_with_loss.json'),
      headers: {}
    )
  end
end

RSpec.configure { |config| config.include HuobiHelper }
