class Exchange::Bitget::BaseResponse
  attr_reader :response
  def initialize(response)
    @response = response
  end

  def success?
    true
  end
end