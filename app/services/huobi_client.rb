class HuobiClient
  def self.host
    @host ||= Rails.application.config_for(:huobi)[:host]
  end

  def initialize(user)
    @access_key = user.huobi_access_key
    @secret_key = user.huobi_secret_key
    @signature_version = '2'
    #@host = "api.huobi.pro"
    @host = HuobiClient.host
    @uri = URI.parse "https://#{@host}/"
    @header = {
      'Content-Type'=> 'application/json',
      'Accept' => 'application/json',
      'Accept-Language' => 'zh-CN',
      'User-Agent'=> 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36'
    }
  end

  def contract_balance(currency)
    path = "/linear-swap-api/v1/swap_balance_valuation"
    params ={valuation_asset: currency}
    request_method = "POST"
    util(path,params,request_method)
  end

  def contract_info(contract_code)
    path = "/linear-swap-api/v1/swap_contract_info"
    params ={contract_code: contract_code, support_margin_mode: 'all'}.stringify_keys
    request_method = "GET"
    util(path,params,request_method)
  end

  def price_limit(contract_code)
    path = "/linear-swap-api/v1/swap_price_limit"
    params ={contract_code: contract_code}.stringify_keys
    request_method = "GET"
    util(path,params,request_method)
  end

  def order_info(contract_code:, client_order_id: nil, order_id: nil )
    path = "/linear-swap-api/v1/swap_cross_order_info"
    params ={order_id: order_id, contract_code: contract_code, client_order_id: client_order_id}.stringify_keys
    request_method = "POST"
    util(path,params,request_method)
  end

  def contract_place_order(order_id:, contract_code:, price:, volume:, direction:, offset:, lever_rate:, order_price_type:)
    path = "/linear-swap-api/v1/swap_cross_order"
    params ={
      contract_code: contract_code,
      # TODO use uniq id
      client_order_id: order_id,
      price: price,
      volume: volume,
      direction: direction,
      offset: offset,
      lever_rate: lever_rate,
      order_price_type: order_price_type
    }
    request_method = "POST"
    util(path,params,request_method)
  end

  def current_position(contract_code)
    path = "/linear-swap-api/v1/swap_cross_position_info"
    params ={contract_code: contract_code}
    request_method = "POST"
    util(path,params,request_method)
  end


  private

  def util(path,params,request_method)
    h =  {
      "AccessKeyId"=>@access_key,
      "SignatureMethod"=>"HmacSHA256",
      "SignatureVersion"=>@signature_version,
      "Timestamp"=> Time.now.getutc.strftime("%Y-%m-%dT%H:%M:%S")
    }
    h = h.merge(params) if request_method == "GET"
    data = "#{request_method}\n#{@host}\n#{path}\n#{Rack::Utils.build_query(hash_sort(h))}"
    h["Signature"] = sign(data)
    url = "https://#{@host}#{path}?#{Rack::Utils.build_query(h)}"
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = true
    begin
      JSON.parse http.send_request(request_method, url, JSON.dump(params), @header).body
    rescue Exception => e
      {"message" => 'error' ,"request_error" => e.message}
    end
  end

  def sign(data)
    Base64.encode64(OpenSSL::HMAC.digest('sha256',@secret_key,data)).gsub("\n","")
  end

  def hash_sort(ha)
    Hash[ha.sort_by{|key, val|key}]
  end
end

