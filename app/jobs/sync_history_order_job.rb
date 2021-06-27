class SyncHistoryOrderJob
  include Sidekiq::Worker

  def perform
    User.all.each do |u|
      u.supported_exchanges.each do |exchange_id|
        exchange_class = Exchange::Entry.find(exchange_id)
        Setting.support_currencies.each do |currency|
          begin
            exchange_class.new(u, currency).sync_full_history do |result|
              HistoryOrder.create!(
                profit: result.real_profit,
                exchange: exchange_id,
                currency: currency,
                volume: result.closed_volume,
                order_placed_at:  result.created_at,
                fees: result.fee,
                remote_order_id: result.order_id,
                trade_avg_price: result.trade_avg_price,
                user_id: u.id
              )
            end
          rescue ActiveRecord::RecordNotUnique => e
            # Do nothing. the record has been synced to the latest.
          end
        end
      end
    end
  end
end