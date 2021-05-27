class WebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def alert
    Rails.logger.info("[alert_log] ip=#{request.remote_ip} params=#{params.inspect}")
    return render_text('001') unless valid_ips?
    return render_text('./app/services/huobi_information_service.rb
004') unless %w[buy sell].include?(alert_params[:direction])
    return render_text('002') unless alert_params[:ticker].end_with?("USDT")
    currency = alert_params[:ticker].sub(/USDT$/, '')
    return render_text('005') unless Setting.support_currencies.include?(currency)
    user = User.find_by(webhook_token: alert_params[:token])
    return render_text('003') unless user

    order_execution = OrderExecution.create!(
      user_id: user.id,
      currency: currency,
      direction: alert_params[:direction]
    )
    PlaceOrderService.new(user, order_execution).execute

    render inline: "success"
  end

  private
  def render_text(text)
    render inline: text
  end

  def valid_ips?
    valid_ips.include?(request.remote_ip)
  end

  def valid_ips
    %w[52.89.214.238 34.212.75.30 54.218.53.128 52.32.178.7]
  end

  def alert_params
    params.permit(:token, :direction, :ticker)
  end
end