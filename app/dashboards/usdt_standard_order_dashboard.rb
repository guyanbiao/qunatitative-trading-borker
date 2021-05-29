require "administrate/base_dashboard"

class UsdtStandardOrderDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    contract_code: Field::String,
    remote_order_id: Field::Number,
    client_order_id: Field::Number,
    user_id: Field::Number,
    open_price: Field::String.with_options(searchable: false),
    close_price: Field::String.with_options(searchable: false),
    volume: Field::Number,
    direction: Field::String,
    offset: Field::String,
    order_price_type: Field::String,
    status: Field::String,
    remote_status: Field::Number,
    parent_order_id: Field::Number,
    order_execution_id: Field::Number,
    lever_rate: Field::Number,
    profit: Field::String.with_options(searchable: false),
    real_profit: Field::String.with_options(searchable: false),
    trade_avg_price: Field::String.with_options(searchable: false),
    fee: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    contract_code
    remote_order_id
    client_order_id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    contract_code
    remote_order_id
    client_order_id
    user_id
    open_price
    close_price
    volume
    direction
    offset
    order_price_type
    status
    remote_status
    parent_order_id
    order_execution_id
    lever_rate
    profit
    real_profit
    trade_avg_price
    fee
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    contract_code
    remote_order_id
    client_order_id
    user_id
    open_price
    close_price
    volume
    direction
    offset
    order_price_type
    status
    remote_status
    parent_order_id
    order_execution_id
    lever_rate
    profit
    real_profit
    trade_avg_price
    fee
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how usdt standard orders are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(usdt_standard_order)
  #   "UsdtStandardOrder ##{usdt_standard_order.id}"
  # end
end
