class HomeController < ApplicationController
  def index
    @currency = current_user.order_executions.last&.currency || Setting.support_currencies.first
    @exchange = current_user.get_exchange(@currency)
    if @exchange.credentials_set?
      @position =  @exchange.current_position
      @orders = @exchange.closed_orders
    else
      @position = nil
      @orders = []
    end
  end
end