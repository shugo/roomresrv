# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161015053653) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "offices", force: :cascade do |t|
    t.string   "name",                     null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "lock_version", default: 0, null: false
    t.index ["name"], name: "index_offices_on_name", unique: true, using: :btree
  end

  create_table "reservation_cancels", force: :cascade do |t|
    t.integer  "reservation_id"
    t.date     "start_on",       null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["reservation_id", "start_on"], name: "index_reservation_cancels_on_reservation_id_and_start_on", unique: true, using: :btree
    t.index ["reservation_id"], name: "index_reservation_cancels_on_reservation_id", using: :btree
  end

  create_table "reservations", force: :cascade do |t|
    t.integer  "room_id",                      null: false
    t.string   "representative",               null: false
    t.string   "purpose",                      null: false
    t.string   "num_participants"
    t.datetime "start_at",                     null: false
    t.datetime "end_at",                       null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "repeating_mode",   default: 0, null: false
    t.integer  "lock_version",     default: 0, null: false
    t.index ["end_at"], name: "index_reservations_on_end_at", using: :btree
    t.index ["repeating_mode"], name: "index_reservations_on_repeating_mode", using: :btree
    t.index ["room_id"], name: "index_reservations_on_room_id", using: :btree
    t.index ["start_at"], name: "index_reservations_on_start_at", using: :btree
  end

  create_table "rooms", force: :cascade do |t|
    t.integer  "office_id",                null: false
    t.string   "name",                     null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "lock_version", default: 0, null: false
    t.index ["office_id", "name"], name: "index_rooms_on_office_id_and_name", unique: true, using: :btree
    t.index ["office_id"], name: "index_rooms_on_office_id", using: :btree
  end

  add_foreign_key "reservation_cancels", "reservations"
  add_foreign_key "reservations", "rooms"
  add_foreign_key "rooms", "offices"
end
