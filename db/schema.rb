# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_20_103822) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alert_logs", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "content"
    t.text "source_type"
    t.bigint "source_id"
    t.string "ip_address"
    t.string "error_code"
    t.string "error_message"
    t.string "status"
    t.boolean "ignored"
  end

  create_table "history_orders", force: :cascade do |t|
    t.string "symbol"
    t.decimal "profit"
    t.string "exchange"
    t.string "currency"
    t.bigint "volume"
    t.datetime "order_placed_at"
    t.decimal "fees"
    t.string "remote_order_id"
    t.decimal "trade_avg_price"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_placed_at"], name: "index_history_orders_on_order_placed_at"
    t.index ["remote_order_id"], name: "index_history_orders_on_remote_order_id", unique: true
    t.index ["user_id", "order_placed_at"], name: "index_history_orders_on_user_id_and_order_placed_at"
    t.index ["user_id"], name: "index_history_orders_on_user_id"
  end

  create_table "manual_batch_executions", force: :cascade do |t|
    t.string "action"
    t.bigint "trader_id"
    t.jsonb "action_params"
    t.bigint "user_ids", array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "order_execution_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "order_execution_id"
    t.string "action"
    t.string "response"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "trader_id"
    t.jsonb "meta"
    t.index ["user_id"], name: "index_order_execution_logs_on_user_id"
  end

  create_table "order_executions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "status"
    t.string "currency"
    t.string "direction"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "exchange_id"
    t.bigint "trader_id"
    t.bigint "batch_execution_id"
    t.string "action"
    t.index ["user_id"], name: "index_order_executions_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "traders", force: :cascade do |t|
    t.string "webhook_token"
    t.boolean "receiving_alerts", default: true
    t.string "exchange_id"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "wx_open_id"
  end

  create_table "trading_strategies", force: :cascade do |t|
    t.bigint "trader_id"
    t.string "name"
    t.integer "max_consecutive_fail_times"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "usdt_standard_orders", force: :cascade do |t|
    t.string "contract_code"
    t.bigint "remote_order_id"
    t.bigint "client_order_id"
    t.bigint "user_id"
    t.decimal "open_price"
    t.decimal "close_price"
    t.bigint "volume"
    t.string "direction"
    t.string "offset"
    t.string "order_price_type"
    t.string "status"
    t.integer "remote_status"
    t.bigint "parent_order_id"
    t.bigint "order_execution_id"
    t.bigint "lever_rate"
    t.decimal "profit"
    t.decimal "real_profit"
    t.decimal "trade_avg_price"
    t.decimal "fee"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "exchange_id"
    t.index ["client_order_id"], name: "index_usdt_standard_orders_on_client_order_id", unique: true
    t.index ["remote_order_id"], name: "index_usdt_standard_orders_on_remote_order_id"
    t.index ["user_id"], name: "index_usdt_standard_orders_on_user_id"
  end

  create_table "user_tags", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_user_tags_on_name"
    t.index ["user_id"], name: "index_user_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "huobi_access_key"
    t.string "huobi_secret_key"
    t.decimal "first_order_percentage"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "lever_rate"
    t.string "webhook_token"
    t.string "bitget_access_key"
    t.string "bitget_secret_key"
    t.string "bitget_pass_phrase"
    t.string "exchange"
    t.boolean "receiving_alerts", default: true
    t.bigint "trader_id"
    t.string "name"
    t.string "phone_number"
    t.boolean "enable", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
