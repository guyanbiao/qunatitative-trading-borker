class PlaceOrderService
  # 机器人需要获取 下单前交易所账户资金信息（根据资金情况算出下单资金），
  # 杠杆倍数，当前最新价。收集完这三 信息 根据指标题是开始下单。
  # 在下单的同时 需要扫描账户现在是否有持仓情况和盈利情况，如果有持仓需要把仓位清除再进行下单。
  #
  # 1.下单资金 以0.5%的资金作为标准仓位 0.5%仓位进场，如果亏损，第二单1%
  # ,第三单1.5%，第四单2%，第五单2.5%，第六单3%以此类推最多到第六单。如果六单全部亏损，第七
  # 单恢复标准仓位0.5%。
  # 2.如果首单0.5%盈利则第二单还是0.5%，不管第几单
  # 盈利只要有盈利下一单恢复标准仓位0.5%。
  #
  # 3.当盈利后  按照收益率100%的倍数止盈，比如当收益率达到100%止盈本金的10%，
  # 收益率达到200% 再止盈本金的 10%， 以此类推止盈到500%。
  # 比如开仓资金100U 当收益率达到100%止盈本金的10%（10U）。200%时再次止盈本金的10%（10U）
  # 以此类推到 500%.  剩下的仓位 就随指标的提示去操作。
  DEFAULT_PERCENTAGE = 0.005.to_d
  DEFAULT_LEVER_RATE = 100
  MAX_CONTINUOUS_FAILURE_TIMES = 5

  attr_reader :order_execution, :currency, :request_direction, :user
  def initialize(user, order_execution)
    @user = user
    @order_execution = order_execution
    @currency = order_execution.currency.upcase
    @request_direction = order_execution.direction
  end

  def execute
    validate

    case order_execution.status.to_sym
    when :created
      handle_created
    when :new_order
      handle_close_order_finished
    when :close_order_placed
      client_order_id = UsdtStandardOrder.where(
        order_execution_id: order_execution.id,
        offset: 'close'
      ).last.client_order_id
      handle_close_order_placed(client_order_id)
    when :close_order_finished
      handle_close_order_finished
    when :open_order_placed
      client_order_id = UsdtStandardOrder.where(
        order_execution_id: order_execution.id,
        offset: 'open'
      ).last.client_order_id
      handle_open_order_placed(client_order_id)
    end
  end

  def validate
    # TODO execution handle timeout
  end

  def validate_remote_order_count
    # TODO validate remote order count
  end

  def handle_open_order_placed(client_order_id)
    remote_order_info = client.order_info(contract_code: contract_code, client_order_id: client_order_id)
    OrderExecutionLog.create!(
      order_execution_id: order_execution.id,
      action: 'query_open_position',
      response: remote_order_info,
      user_id: user.id
    )
    if remote_order_info['status'] == 'ok'
      order = UsdtStandardOrder.find_by(client_order_id: client_order_id)
      data = remote_order_info['data'].first
      order.update(
        open_price: data['price'],
        remote_status: data['status']
      )
      if data['status'] == UsdtStandardOrder::RemoteStatus::FINISHED
        order_execution.open_confirm
        order_execution.save!
      end
    end
  end

  def handle_close_order_finished
    validate_remote_order_count

    client_order_id = generate_order_id
    open_position(client_order_id)
  end

  def handle_close_order_placed(client_order_id)
    remote_order_info = client.order_info(contract_code: contract_code, client_order_id: client_order_id)
    OrderExecutionLog.create!(
      order_execution_id: order_execution.id,
      action: 'query_close_position',
      response: remote_order_info,
      user_id: user.id
    )
    data = remote_order_info['data'].first
    if remote_order_info['status'] == 'ok' && data['status'] == UsdtStandardOrder::RemoteStatus::FINISHED
      ActiveRecord::Base.transaction do
        order_execution.close_finish
        order_execution.save!
        close_order = UsdtStandardOrder.find_by(client_order_id: client_order_id)
        open_order = last_order
        open_order.finish
        open_order.assign_attributes(
          profit: data['profit'],
          real_profit: data['real_profit'],
          trade_avg_price: data['trade_avg_price'],
          fee: data['fee'],
          remote_status: data['status']
        )
        open_order.save!
        close_order.finish
        close_order.assign_attributes(
          profit: data['profit'],
          real_profit: data['real_profit'],
          trade_avg_price: data['trade_avg_price'],
          fee: data['fee'],
          remote_status: data['status']
        )
        close_order.save!
      end
      handle_close_order_finished
    end
  end

  def handle_created
    if has_position?
      client_order_id = generate_order_id
      close_position(client_order_id)
    else
      order_execution.open_new_order
      order_execution.save!
      handle_close_order_finished
    end
  end

  def has_position?
    @has_position ||= last_order && last_order.status == 'processing'
  end

  def remote_orders_count
  end

  def close_position(client_order_id)
    opposite_direction = last_order.direction == 'buy'  ? 'sell' : 'buy'
    result = client.contract_place_order(
      order_id: client_order_id,
      contract_code: contract_code,
      price: nil,
      volume: last_order.volume,
      direction: opposite_direction,
      offset: 'close',
      lever_rate: last_order.lever_rate,
      order_price_type: order_price_type,
    )
    OrderExecutionLog.create!(
      order_execution_id: order_execution.id,
      action: 'close_position',
      response: result,
      user_id: user.id
    )
    if result['status'] == 'ok'
      ActiveRecord::Base.transaction do
        create_order!(
          remote_order_id: result['data']['order_id'],
          client_order_id: client_order_id,
          direction: opposite_direction,
          parent_order_id: last_order.id,
          offset: 'close',
          volume: last_order.volume,
          lever_rate: last_order.lever_rate
        )
        order_execution.close
        order_execution.save!
      end
      handle_close_order_placed(client_order_id)
    end
  end

  def generate_order_id
    # TODO use database id?
    rand(9223372036854775807)
  end

  def open_position(client_order_id)
    volume = calculate_open_position_volume
    result = client.contract_place_order(
      order_id: client_order_id,
      contract_code: contract_code,
      price: nil,
      volume: volume,
      direction: request_direction,
      offset: 'open',
      lever_rate: lever_rate,
      order_price_type: order_price_type
    )
    OrderExecutionLog.create!(
      order_execution_id: order_execution.id,
      action: 'open_position',
      response: result,
      user_id: user.id
    )
    if result['status']  == 'ok'
      ActiveRecord::Base.transaction do
        order_execution.open_order
        order_execution.save!
        create_order!(
          client_order_id: client_order_id,
          remote_order_id: result['data']['order_id'],
          direction: request_direction,
          offset: 'open',
          volume: volume,
          lever_rate: lever_rate )
      end
      handle_open_order_placed(client_order_id)
    else
      Rails.logger.info("[open position fail] result = #{result}")
      puts result
    end
  end

  def create_order!(client_order_id:, remote_order_id:, direction:, offset:, volume:, lever_rate:, parent_order_id: nil)
    UsdtStandardOrder.create!(
      volume: volume,
      client_order_id: client_order_id,
      remote_order_id: remote_order_id,
      order_execution_id: order_execution.id,
      contract_code: contract_code,
      direction: direction,
      offset: offset,
      lever_rate: lever_rate,
      order_price_type: order_price_type,
      parent_order_id: parent_order_id,
      user_id: user.id
    )
  end

  def open_position_service
    @open_position_service ||= OpenPositionService.new(user, currency)
  end

  def calculate_open_position_volume
    open_position_service.calculate_open_position_volume
  end

  def balance
    begin
      result = client.contract_balance('USDT')
      balance = result['data'].find {|i| i['valuation_asset'] == 'USDT'}
      balance['balance'].to_d
    rescue
      0.to_d
    end
  end

  def last_order
    @last_order ||= UsdtStandardOrder.order(:created_at).open.where(user_id: user.id).last
  end

  def lever_rate
    @lever_rate ||= user.lever_rate || DEFAULT_LEVER_RATE
  end

  def order_price_type
    'opponent'
  end

  def contract_code
    "#{currency}-USDT"
  end

  def client
    @client ||= HuobiClient.new(user)
  end
end