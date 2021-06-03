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
      body: file_fixture('bitget/accounts.json'),
      headers: {}
    )
  end
end

RSpec.configure { |config| config.include BitgetHelper }