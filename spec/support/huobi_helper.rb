# frozen_string_literal: true

module HuobiHelper
  def stub_place_order
    r = Regexp.new( "https://huobi.test.com/linear-swap-api/v1/swap_cross_order\\?.*" )
    stub_request(:post, r).to_return(
      status: 200,
      body: file_fixture('swap_cross_order.json'),
      headers: {}
    )
  end
end

RSpec.configure { |config| config.include HuobiHelper }
