class WebhookHandlingService
  attr_reader :alert_params, :request
  ERROR_DIC = {
    '001' => 'invalid ip',
    '004' => 'invalid direction',
    '002' => 'invalid currency',
    '005' => 'currency not support',
    '003' => 'resource not found',
  }

  def initialize(alert_params, request)
    @alert_params = alert_params
    @request = request
  end

  def execute
    create_webhook_log
    validate!
    return unless trader.receiving_alerts
    BatchTradeService.new(trader: trader, currency: currency, direction: alert_params[:direction]).execute
  end

  def create_webhook_log
    AlertLog.create(
      content: alert_params.to_json,
      source_type: 'trader',
      source_id: trader&.id,
      ip_address: ip_address,
      error_code: error_code,
      error_message: error_message,
      status: status,
      ignored: ignored
    )
  end

  def ignored
    return true unless trader
    !trader.receiving_alerts
  end

  def status
    @status ||= if error_code
      'error'
    else
      'ok'
    end
  end

  def error_message
    @error_message ||= ERROR_DIC[error_code]
  end

  def error_code
    @error_code ||=
      begin
        if !valid_ips?
          '001'
        elsif !%w[buy sell].include?(alert_params[:direction])
          '004'
        elsif !alert_params[:ticker].end_with?("USDT")
          'invalid_currency'
        elsif !Setting.support_currencies.include?(currency)
          '005'
        elsif !trader
          '003'
        else
          nil
        end
      end
  end

  def validate!
    if error_code
      raise Webhook::InvalidContentError.new(error_code)
    end
  end

  def currency
    alert_params[:ticker].sub(/USDT$/, '')
  end

  def trader
    Trader.find_by(webhook_token: alert_params[:token])
  end


  def ip_address
    @ip_address ||= request.remote_ip
  end

  def valid_ips?
    valid_ips.include?(ip_address)
  end

  def valid_ips
    %w[52.89.214.238 34.212.75.30 54.218.53.128 52.32.178.7]
  end
end