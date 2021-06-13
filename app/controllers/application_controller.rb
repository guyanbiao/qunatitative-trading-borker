class ApplicationController < ActionController::Base
  before_action :authenticate_trader!

  rescue_from ExchangeClients::Bitget::AuthFailError, with: :auth_fai

  def auth_fai(e)
    Rails.logger.info("user_id=#{current_trader.id} error=#{e}")
    flash[:alert] = 'bitget 密钥错误请检查'
    redirect_to settings_path
  end
end