class WeixinController < ApplicationController
  skip_before_action :authenticate_trader!
  skip_before_action :verify_authenticity_token

  def callback
    render inline: params[:echostr]
  end

  def redirect
    result = WeixinAuthorize.http_get_without_token("/sns/oauth2/access_token?appid=#{WeixinService.app_id}&secret=#{WeixinService.app_secret}&code=#{params[:code]}&grant_type=authorization_code", {}, "api")
    puts result
    Rails.logger.info("weixin_result #{result.to_json}")
    if result.is_ok?
      redirect_to wexin_new_bind_path(wx_open_id: result['result']['openid'])
    else
      render json: result
    end
  end

  def new_bind
    @trader = Trader.new
  end

  def bind
    # TODO add redis token
   trader = Trader.find_by(email: bind_params[:email])
   unless trader && trader.valid_password?(bind_params[:password])
     flash[:alert] = 'wrong credentials'
     redirect_back(fallback_location: '/')
     return
   end

   if trader.update(wx_open_id: params.permit(:wx_open_id)[:wx_open_id])
     render inline: 'success'
   else
     flash[:alert] = trader.errors.full_messages.join(',')
     redirect_back(fallback_location: '/')
   end
  end

  private
  def bind_params
    params.require(:trader).permit(:email, :password)
  end
end