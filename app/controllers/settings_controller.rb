class SettingsController < ApplicationController
  def index
  end

  def create
    current_user.update(
      huobi_access_key: params[:access_key],
      huobi_secret_key: params[:secret_key]
    )
    flash[:notice] = '更新成功'
    redirect_back(fallback_location: '/settings')
  end

  def update_percentage
    if current_user.update(
      first_order_percentage: percentage_params[:first_order_percentage].to_d,
      )
      flash[:notice] = '更新成功'
    else
      flash[:alert] = '更新失败'
    end
    redirect_back(fallback_location: '/settings')
  end

  def percentage_params
    params.require(:user).permit(:first_order_percentage)
  end
end
