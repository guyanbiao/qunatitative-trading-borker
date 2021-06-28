# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  # Define your fields
  # field :host, type: :string, default: "http://localhost:3000"
  # field :default_locale, default: "en", type: :string
  # field :confirmable_enable, default: "0", type: :boolean
  # field :admin_emails, default: "admin@rubyonrails.org", type: :array
  # field :omniauth_google_client_id, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_ID"] || ""), type: :string, readonly: true
  # field :omniauth_google_client_secret, default: (ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"] || ""), type: :string, readonly: true
  #
  field :huobi_access_key, type: :string
  field :huobi_secret_key, type: :string
  field :place_order_default_percentage, type: :string
  field :support_currencies, type: :array, default: ['BTC', 'ETH']
  field :default_trading_strategy, type: :string, default: 'tier'
  field :max_consecutive_fail_times, type: :integer, default: 5
end
