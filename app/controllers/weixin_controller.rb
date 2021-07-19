class WeixinController < ApplicationController
  skip_before_action :authenticate_trader!
  skip_before_action :verify_authenticity_token

  def callback
    render inline: params[:signature]
  end
end