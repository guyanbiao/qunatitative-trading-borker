class UsdtStandardOrdersController < ApplicationController
  def close_position
    @order = UsdtStandardOrder.find(close_position_params[:id])
    result = ClosePositionService.new(@order, generate_order_id).execute
    if result['status'] == 'ok'
      flash[:notice] = '平仓成功'
    else
      flash[:alert] = result['err_msg']
    end
    redirect_back(fallback_location: '/')
  end

  def close_position_params
    params.permit([:id])
  end

  def generate_order_id
    # TODO use database id?
    rand(9223372036854775807)
  end
end
