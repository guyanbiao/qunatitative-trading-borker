class WebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def alert
    Rails.logger.info("[alert_log] ip=#{request.remote_ip} params=#{params.inspect}")
    begin
      WebhookHandlingService.new(alert_params, request).execute
      render inline: "success"
    rescue Webhook::InvalidContentError => e
      render inline: e.error_code
    end
  end

  private
  def alert_params
    params.permit(:token, :direction, :ticker)
  end
end