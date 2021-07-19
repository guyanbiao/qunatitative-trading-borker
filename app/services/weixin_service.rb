class WeixinService
  def self.client
    @__wx_client ||= WeixinAuthorize::Client.new(app_id, app_secret)
  end

  def self.app_id
    ENV["WX_APPID"]
  end

  def self.app_secret
    ENV["WX_APPSECRET"]
  end
end