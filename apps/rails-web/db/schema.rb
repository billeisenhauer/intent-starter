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

ActiveRecord::Schema[7.2].define(version: 2026_01_15_033809) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "availability_observations", force: :cascade do |t|
    t.bigint "title_id", null: false
    t.string "platform", null: false
    t.bigint "observer_id", null: false
    t.decimal "confidence", precision: 5, scale: 4, null: false
    t.datetime "observed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["observed_at"], name: "index_availability_observations_on_observed_at"
    t.index ["observer_id"], name: "index_availability_observations_on_observer_id"
    t.index ["title_id", "platform", "observer_id"], name: "idx_availability_obs_title_platform_observer"
    t.index ["title_id"], name: "index_availability_observations_on_title_id"
  end

  create_table "households", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade do |t|
    t.bigint "household_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id", "name"], name: "index_members_on_household_id_and_name", unique: true
    t.index ["household_id"], name: "index_members_on_household_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "household_id", null: false
    t.string "platform", null: false
    t.decimal "monthly_cost", precision: 8, scale: 2, null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_watched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_subscriptions_on_active"
    t.index ["household_id", "platform"], name: "index_subscriptions_on_household_id_and_platform", unique: true
    t.index ["household_id"], name: "index_subscriptions_on_household_id"
  end

  create_table "titles", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "name", null: false
    t.string "title_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_titles_on_external_id", unique: true
    t.index ["title_type"], name: "index_titles_on_title_type"
  end

  create_table "viewing_records", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.bigint "title_id", null: false
    t.decimal "progress", precision: 5, scale: 4, default: "0.0", null: false
    t.boolean "fully_watched", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fully_watched"], name: "index_viewing_records_on_fully_watched"
    t.index ["member_id", "title_id"], name: "index_viewing_records_on_member_id_and_title_id", unique: true
    t.index ["member_id"], name: "index_viewing_records_on_member_id"
    t.index ["title_id"], name: "index_viewing_records_on_title_id"
  end

  add_foreign_key "availability_observations", "members", column: "observer_id"
  add_foreign_key "availability_observations", "titles"
  add_foreign_key "members", "households"
  add_foreign_key "subscriptions", "households"
  add_foreign_key "viewing_records", "members"
  add_foreign_key "viewing_records", "titles"
end
