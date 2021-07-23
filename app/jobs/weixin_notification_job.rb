class WeixinNotificationJob
  include Sidekiq::Worker

  def perform(order_execution_id)
    order_execution = OrderExecution.find(order_execution_id)
    return unless order_execution.trader.wx_open_id
    WeixinService.client.send_template_msg(
      order_execution.trader.wx_open_id,
      template_id,
      'http://trading.igolife.net/',
      'red',
      {
        first: {value: "订单完成"},
        keyword1: {value: order_execution.currency},
        keyword2: {value: order_execution.direction}
      })
  end

  private
  def template_id
    'QO9iXn91g9nt-oiwwnVajUR4cHeiB5zY_sLexxd-LzU'
  end
end