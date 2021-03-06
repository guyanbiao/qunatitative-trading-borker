class BitGetApiClient
  def self.host
    @host ||= Rails.application.config_for(:bitget)[:host]
  end

  GET = 'GET'
  POST = 'POST'
  API_URL = 'https://capi.bitgetapi.com'
  #API_KEY = 'bg_f32b97dc639ed8fa7a7957cca31c5311'
  #API_SECRET_KEY = 'ddc5ef6d7829dda3daecb0c9b8f1d2a54601ed20559e3db4edb22e59a6b97506'
  # PASS_PRAHSE = 'gg785236'

  def initialize(user)
    @api_key = user.bitget_access_key
    @secret_key = user.bitget_secret_key
    @pass_phrase = user.bitget_pass_phrase
  end

  def accounts
    path = '/api/swap/v3/account/accounts'
    request('GET', path, {})
  end

  def place_order(symbol:, client_order_id:, size:, type:, order_type:, match_price:, price: )
    path = '/api/swap/v3/order/placeOrder'
    params = {
      symbol: symbol,
      client_oid: client_order_id,
      size: size,
      type: type,
      order_type: order_type,
      match_price: match_price,
      price: price
    }
    request('POST', path, params)
  end

  def order_info(symbol:, remote_order_id:)
    path = '/api/swap/v3/order/detail'
    params = {symbol: symbol, orderId: remote_order_id}
    request('GET', path, params)
  end

  def current_position(symbol:)
    path = '/api/swap/v3/position/singlePosition'
    params = {symbol: symbol}
    request('GET', path, params)
  end

  def history(symbol:, pageIndex: 1)
    path = '/api/swap/v3/order/history'
    params = {symbol: symbol, pageIndex: pageIndex, pageSize: 100, createDate: 90}
    request('GET', path, params)
  end

  def ticker(symbol)
    path = '/api/swap/v3/market/ticker'
    params = {symbol: symbol}
    request('GET', path, params)
  end

  def contracts_info
    path = '/api/swap/v3/market/contracts'
    params = {}
    request('GET', path, params)
  end

  private
  def auth_fail?(code, data)
    return false if code != 400
    return false unless data['code']
    data['code'].in? %w[40006 40012]
  end

  def request(method, request_path, params)
    if method == GET && params.length > 0
      request_path = request_path + "?" + parse_params_to_str(params)
    end
    url = BitGetApiClient.host + request_path
    body = (method == POST) ? params.to_json : nil
    timestamp = (Time.now.to_f * 1000).round.to_s
    sign = get_sign(pre_hash(timestamp, method, request_path, body.to_s), @secret_key)
    header = get_header(sign, timestamp)
    if method == GET
      result = HTTParty.get(url, headers: header, debug_output: STDOUT)
    else
      result = HTTParty.post(url, body: body, headers: header, debug_output: STDOUT)
    end
    data = JSON.parse(result.body)
    if auth_fail?(result.code, data)
      raise ExchangeClients::Bitget::AuthFailError.new(data)
    end
    {
      'data' => data,
      'http_status_code' => result.code
    }
  end

  def parse_params_to_str(params)
    URI.encode_www_form(params)
  end

  def get_header(sign, timestamp)
    header = {}
    header['Content-Type'] = 'application/json'
    header['ACCESS-KEY'] = @api_key
    header['ACCESS-SIGN'] = sign
    header['ACCESS-TIMESTAMP'] = timestamp.to_s
    header['ACCESS-PASSPHRASE'] = @pass_phrase
    header
  end

  def pre_hash(timestamp, method, request_path, body)
    timestamp.to_s + method.upcase + request_path + body.to_s
  end

  def get_sign(message, secret_key)
    Base64.encode64(OpenSSL::HMAC.digest("SHA256", secret_key, message))
  end
end
