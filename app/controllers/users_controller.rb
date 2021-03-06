class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :new_order, :disable, :enable]

  def index
    @users = current_trader.users.order(:created_at)
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

  def new
    @user = current_trader.users.new
    @current_tags = UserTag.distinct.pluck(:name)
  end

  def show
    @currency = get_currency
    @exchange = @user.get_exchange(@currency)
    @orders = @user.history_orders.order(order_placed_at: :desc).page(params[:page]).per(per_page)
    if @exchange.credentials_set?
      @position =  @exchange.current_position
    else
      @position = nil
    end
  end

  def create
    @user = User.new(create_params.merge(trader_id: current_trader.id))
    @user.password = 'gkdd932kasdfiopz@55'
    if @user.save
      update_tags
      redirect_to users_path
    else
      flash[:alert] = @user.errors.full_messages
      render action: :new
    end
  end

  def edit
    @current_tags = UserTag.distinct.pluck(:name)
  end

  def update
    if @user.update(update_params)
      update_tags
      flash[:notice] = '更新成功'
    else
      flash[:alert] = @user.errors.full_messages
    end
    redirect_to(users_path)
  end

  def disable
    @user.update(enable: false)
    redirect_to users_path
  end

  def enable
    @user.update(enable: true)
    redirect_to users_path
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
    params.require(:user).permit(:first_order_percentage,
                                 :lever_rate,
                                 :webhook_token,
                                 :exchange,
                                 :receiving_alerts,
                                 :huobi_access_key,
                                 :huobi_secret_key,
                                 :bitget_access_key,
                                 :bitget_secret_key,
                                 :bitget_pass_phrase,
                                 :email,
                                 :phone_number,
                                 :name,
    )
  end

  def tags_params
    params.require(:user).permit(:tags)[:tags]
  end

  def create_params
    params.require(:user).permit(:first_order_percentage,
                                 :lever_rate,
                                 :webhook_token,
                                 :exchange,
                                 :receiving_alerts,
                                 :huobi_access_key,
                                 :huobi_secret_key,
                                 :bitget_access_key,
                                 :bitget_secret_key,
                                 :bitget_pass_phrase,
                                 :email,
                                 :phone_number,
                                 :name,
    )
  end

  def per_page
    10
  end

  def update_tags
    tags = tags_params.to_s.split(",")
    tags.each do |name|
      @user.user_tags.where(name: name).first_or_create!
    end
    (@user.user_tags.map(&:name) - tags).each do |name|
      @user.user_tags.find_by(name: name).destroy!
    end
  end
end