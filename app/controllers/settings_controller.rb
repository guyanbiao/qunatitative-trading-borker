class SettingsController < ApplicationController
  def index
  end

  def create
    current_trader.update(create_params.select {|k, v| v.present?} )
    flash[:notice] = '更新成功'
    redirect_back(fallback_location: '/settings')
  end

  def update_percentage
    if current_trader.update( percentage_params )
      flash[:notice] = '更新成功'
    else
      flash[:alert] = "#{current_trader.errors.full_messages}"
    end
    redirect_back(fallback_location: '/settings')
  end

  def percentage_params
    params.require(:user).permit(:first_order_percentage, :lever_rate, :webhook_token, :exchange, :receiving_alerts)
  end

  def create_params
    params.permit(:huobi_access_key, :huobi_secret_key, :bitget_access_key, :bitget_secret_key, :bitget_pass_phrase)
  end
end
