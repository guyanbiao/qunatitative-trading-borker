class SettingsController < ApplicationController
  def index
  end

  def create
    Setting.huobi_access_key = params[:access_key]
    Setting.huobi_secret_key = params[:secret_key]
    flash[:notice] = '更新成功'
    redirect_back(fallback_location: '/settings')
  end
end
