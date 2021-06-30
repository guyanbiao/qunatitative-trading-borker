class HealthController < ApplicationController
  skip_before_action :authenticate_trader!
  skip_before_action :verify_authenticity_token
  
  def check
    render inline: 'ok'
  end
end