class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :new_order]

  def index
    @users = current_trader.users
  end

  def new_order
    @default_option = params[:symbol].present? ? params[:symbol].upcase : Setting.support_currencies.first
    exchange = @user.exchange_class.new(@user, @default_option)
    unless exchange.credentials_set?
      flash[:alert] = "请先设置 #{exchange.id} 交易所的密钥"
      redirect_to(edit_user_path(@user))
      return
    end
    @ops = OpenPositionService.new(@user, @default_option, exchange)
    @order_execution = OrderExecution.new(currency: @default_option)
  end

  def show
    @currency = get_currency
    @exchange = @user.get_exchange(@currency)
    if @exchange.credentials_set?
      @position =  @exchange.current_position
      @orders = @exchange.closed_orders
    else
      @position = nil
      @orders = []
    end
  end

  def edit
  end

  def update
    if @user.update(update_params)
      flash[:notice] = '更新成功'
    else
      flash[:alert] = @user.errors.full_messages
    end
    redirect_to(user_path(@user.id))
  end

  private
  def set_user
    @user = current_trader.users.find(user_params[:id])
  end

  def get_currency
    params[:currency] || @user.order_executions.last&.currency || Setting.support_currencies.first
  end

  def user_params
    params.permit(:id)
  end

  def update_params
    params.require(:user).permit(:first_order_percentage, :lever_rate, :webhook_token, :exchange, :receiving_alerts, :huobi_access_key, :huobi_secret_key, :bitget_access_key, :bitget_secret_key, :bitget_pass_phrase)
  end
end