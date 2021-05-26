class HuobiInformationService
  attr_reader :user, :currency

  def initialize(user, currency)
    @user = user
    @currency = currency
  end

  def current_price
    result = client.price_limit("#{currency}-USDT")
    item = result['data'].find {|i| i['symbol'] == currency}
    raise "price not found #{result}" unless item
    item['high_limit'].to_d
  end

  def contract_unit_price
    client.contract_info(contract_code)['data'].last['contract_size'].to_d
  end

  def client
    @client ||= HuobiClient.new(user)
  end

  def contract_code
    "#{currency}-USDT"
  end
end