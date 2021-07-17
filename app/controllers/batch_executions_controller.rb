class BatchExecutionsController < ApplicationController
  before_action :set_batch_execution, only: [:show]
  def new
    @users = current_trader.users
  end

  def show
    @order_executions = @batch_execution.order_executions.joins(:user).page(params[:page]).per(20)
    @users = @batch_execution.users
  end

  def index
    @batch_executions = current_trader.manual_batch_executions.page(params[:page]).per(20)
  end

  def create
    batch_execution = ManualBatchTradeService.new.create(
      trader: current_trader,
      currency: create_params[:currency],
      direction: create_params[:direction],
      action: create_params[:action],
      user_ids: create_params[:users]
    )
    redirect_to batch_execution_path(batch_execution)
  end

  private
  def create_params
    params.require(:batch_execution).permit(:action, :currency, :direction, users: [])
  end

  def set_batch_execution
    @batch_execution = current_trader.manual_batch_executions.find(params[:id])
  end
end