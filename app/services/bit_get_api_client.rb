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

  def request(method, request_path, params)
    if method == GET
      request_path = request_path + parse_params_to_str(params)
    end
    url = BitGetApiClient.host + request_path
    body = (method == POST) ? params.to_json : nil
    timestamp = (Time.now.to_f * 1000).round.to_s
    sign = get_sign(pre_hash(timestamp, method, request_path, body.to_s), @secret_key)
    header = get_header(sign, timestamp)
    if method == GET
      result = HTTParty.get(url, headers: header)
    else
      result = HTTParty.post(url, body: body, headers: header, debug_output: STDOUT)
    end

    JSON.parse(result.body)
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
