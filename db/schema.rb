# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160309082337) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "offices", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "lock_version", default: 0, null: false
  end

  create_table "reservations", force: :cascade do |t|
    t.integer  "room_id"
    t.string   "representative"
    t.string   "purpose"
    t.string   "num_participants"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "repeating_mode",   default: 0, null: false
    t.integer  "lock_version",     default: 0, null: false
  end

  add_index "reservations", ["end_at"], name: "index_reservations_on_end_at", using: :btree
  add_index "reservations", ["repeating_mode"], name: "index_reservations_on_repeating_mode", using: :btree
  add_index "reservations", ["room_id"], name: "index_reservations_on_room_id", using: :btree
  add_index "reservations", ["start_at"], name: "index_reservations_on_start_at", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.integer  "office_id"
    t.string   "name"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "lock_version", default: 0, null: false
  end

  add_index "rooms", ["office_id"], name: "index_rooms_on_office_id", using: :btree

  add_foreign_key "reservations", "rooms"
  add_foreign_key "rooms", "offices"
end
