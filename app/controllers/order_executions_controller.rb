class OrderExecutionsController < ApplicationController
  def index
    @order_executions = OrderExecution.where(user_id: current_user.id).order(created_at: :desc).page(params[:page]).per(per_page)
  end

  def new
    @default_option = params[:symbol].present? ? params[:symbol].upcase : Setting.support_currencies.first
    exchange = current_user.exchange_class.new(current_user, @default_option)
    unless exchange.credentials_set?
      flash[:alert] = "请先设置 #{exchange.id} 交易所的密钥"
      redirect_to(settings_path)
      return
    end
    @ops = OpenPositionService.new(current_user, @default_option, exchange)
    @order_execution = OrderExecution.new(currency: @default_option)
  end

  def create
    execution = OrderExecution.create!(create_params.merge(user_id: current_user.id, exchange_id: current_user.exchange_id))
    exchange = current_user.exchange_class.new(current_user, create_params[:currency])
    PlaceOrderService.new(current_user, execution).execute
    redirect_to order_executions_path
  end

  def show
    @order_execution = OrderExecution.find(params[:id])
    @open_order = UsdtStandardOrder.open.where(order_execution_id: @order_execution ).last
    @close_order = UsdtStandardOrder.close.where(order_execution_id: @order_execution ).last
    @logs = @order_execution.logs
  end

  private
  def create_params
    params.require(:order_execution).permit(:currency, :direction)
  end

  def per_page
    20
  end
end
