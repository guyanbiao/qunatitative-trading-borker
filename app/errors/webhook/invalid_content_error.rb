class Webhook::InvalidContentError < StandardError
  attr_reader :error_code
  def initialize(error_code)
    @error_code = error_code
    super("error_code=#{error_code}")
  end
end