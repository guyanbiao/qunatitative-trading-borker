class OrderExecutionsController < ApplicationController
  before_action :set_user, only: [:index, :new, :show]
  def index
    @order_executions = OrderExecution.where(user_id: @user.id).order(created_at: :desc).page(params[:page]).per(per_page)
  end

  def new
    @default_option = params[:symbol].present? ? params[:symbol].upcase : Setting.support_currencies.first
    exchange = @user.exchange_class.new(@user, @default_option)
    unless exchange.credentials_set?
      flash[:alert] = "请先设置 #{exchange.id} 交易所的密钥"
      redirect_to(edit_user_path(@user.id))
      return
    end
    @ops = OpenPositionService.new(@user, @default_option, exchange)
    @order_execution = OrderExecution.new(currency: @default_option, user_id: @user.id)
  end

  def create
    @user = current_trader.users.find(create_params[:user_id])
    execution = OrderExecution.create!(
      create_params.merge(
        user_id: @user.id,
        exchange_id: @user.exchange_id,
        trader_id: current_trader.id)
    )
    PlaceOrderService.new(@user, execution).execute
    redirect_to user_path(@user.id)
  end

  def show
    @order_execution = @user.order_executions.find(params[:id])
    @open_order = UsdtStandardOrder.open.where(order_execution_id: @order_execution).last
    @close_order = UsdtStandardOrder.close.where(order_execution_id: @order_execution).last
    @logs = @order_execution.logs
  end

  private
  def create_params
    params.require(:order_execution).permit(:currency, :direction, :user_id)
  end

  def per_page
    20
  end

  def set_user
    @user = current_trader.users.find(params[:user_id])
  end
end
