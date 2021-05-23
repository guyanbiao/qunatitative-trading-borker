class OrderExecutionsController < ApplicationController
  def index
    @order_executions = OrderExecution.order(created_at: :desc).page(params[:page]).per(per_page)
  end

  def new
    @order_execution = OrderExecution.new
  end

  def create
    execution = OrderExecution.create!(create_params)
    PlaceOrderService.new(execution).execute
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
