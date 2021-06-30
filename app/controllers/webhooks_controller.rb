class WebhooksController < ApplicationController
  skip_before_action :authenticate_trader!
  skip_before_action :verify_authenticity_token

  def alert
    Rails.logger.info("[alert_log] ip=#{request.remote_ip} params=#{params.inspect}")
    Rails.logger.info("[alert_log headers] remote_ip=#{request.headers['X-Forwarded-For']}")
    Rails.logger.info("[alert_log full headers] headers=#{request.headers.to_h}")


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