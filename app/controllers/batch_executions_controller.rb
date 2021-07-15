class BatchExecutionsController < ApplicationController
  def new
    @user = current_trader.users
  end
end