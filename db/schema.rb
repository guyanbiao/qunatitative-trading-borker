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

ActiveRecord::Schema.define(version: 2021_05_23_000605) do

  create_table "order_execution_logs", force: :cascade do |t|
    t.bigint "order_execution_id"
    t.string "action"
    t.string "response"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "order_executions", force: :cascade do |t|
    t.string "status"
    t.string "currency"
    t.string "direction"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "usdt_standard_orders", force: :cascade do |t|
    t.string "contract_code"
    t.bigint "remote_order_id"
    t.bigint "client_order_id"
    t.decimal "open_price"
    t.decimal "close_price"
    t.bigint "volume"
    t.string "direction"
    t.string "offset"
    t.integer "decimal"
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
    t.index ["client_order_id"], name: "index_usdt_standard_orders_on_client_order_id"
    t.index ["remote_order_id"], name: "index_usdt_standard_orders_on_remote_order_id"
  end

end
