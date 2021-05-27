class Query::UsdtStandardOrderService
  def last_finished_close_order(contract_code:, user_id:)
    @last_order ||= UsdtStandardOrder.close.done.where(contract_code: contract_code).order(:created_at).where(user_id: user_id).last
  end
end