class Exchange::Huobi::BaseResponse
  attr_reader :response
  def initialize(response)
    @response = response
  end

  def success?
    response['status']  == 'ok'
  end

  def data
    response['data']
  end
end