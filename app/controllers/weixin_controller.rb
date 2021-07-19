class WeixinController < ApplicationController
  skip_before_action :authenticate_trader!
  skip_before_action :verify_authenticity_token

  def callback
    render inline: params[:echostr]
  end

  def redirect
    result = WeixinAuthorize.http_get_without_token("/sns/oauth2/access_token?appid=#{WeixinService.app_id}&secret=#{WeixinService.app_secret}&code=#{params[:code]}&grant_type=authorization_code", {}, "api")
    puts result
    Rails.logger.info("weixin_result #{result.to_s}")
    render json: result
  end
end