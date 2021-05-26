class WebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  def alert
    validate
    Rails.logger.info(params.inspect)
    render inline: ""
  end

  private
  def validate
    Rails.logger.info(request.remote_ip)
    # TODO validate ip
  end
end