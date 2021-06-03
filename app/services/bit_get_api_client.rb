class BitGetApiClient
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

  def contract_balance(currency)
    path = '/api/swap/v3/account/accounts'
    result = request('GET', path, {})
    ApiClients::Bitget::Responses::ContractBalance.new(result)
  end

  def contract_info(contract_code)
    symbol = "cmt_#{contract_code.downcase}usdt"
    path = '/api/swap/v3/market/contracts'
    result = request('GET', path, {})
  end

  def contracts
    path = '/api/swap/v3/market/contracts'
    request('GET', path, {})
  end

  def accounts
    path = '/api/swap/v3/account/accounts'
    request('GET', path, {})
  end

  def request(method, request_path, params)
    if method == GET
      request_path = request_path + parse_params_to_str(params)
    end
    url = API_URL + request_path
    body = (method == POST) ? params : nil
    timestamp = (Time.now.to_f * 1000).round.to_s
    sign = get_sign(pre_hash(timestamp, method, request_path, body.to_s), @secret_key)
    header = get_header(sign, timestamp)
    JSON.parse(HTTParty.get(url, headers: header).body)
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
