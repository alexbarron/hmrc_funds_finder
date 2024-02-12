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

ActiveRecord::Schema[7.0].define(version: 2024_02_06_134640) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "funds", force: :cascade do |t|
    t.string "letter_group"
    t.string "reporting_fund_ref"
    t.string "parent_fund"
    t.string "hmrc_share_class_ref_no"
    t.string "sub_fund_name"
    t.string "isin_no"
    t.string "cusip_no"
    t.date "reporting_from"
    t.date "ceased_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ticker"
    t.index ["ticker"], name: "index_funds_on_ticker"
  end

end
