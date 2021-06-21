class HomeController < ApplicationController
  def index
    @managed_user_count = current_trader.users.count
    query = query_params.select {|k, v| v.present?}
    @orders = HistoryOrder
      .joins(:user)
      .where({user: {trader_id: current_trader.id}}.merge(query))
      .page(params[:page])
      .per(per_page)

    if params[:start_date].present?
      @orders  = @orders.where('history_orders.order_placed_at > ?', params[:start_date])
    end
    if params[:end_date].present?
      @orders  = @orders.where('history_orders.order_placed_at < ?', params[:end_date])
    end
    @total_profit = @orders.sum(:profit)
  end

  private
  def query_params
    params.permit(:exchange, :currency)
  end

  def per_page
    10
  end
end