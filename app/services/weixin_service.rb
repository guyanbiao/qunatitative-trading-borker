class WeixinService
  def self.client
    @__wx_client ||= WeixinAuthorize::Client.new(ENV["APPID"], ENV["APPSECRET"])
  end
end