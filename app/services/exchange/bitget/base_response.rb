class Exchange::Bitget::BaseResponse
  attr_reader :response
  def initialize(response)
    @response = response
  end

  def success?
    response['http_status_code'] == 200
    # TODO fix this
    true
  end

  def data
    response['data']
  end
end