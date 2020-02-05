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

ActiveRecord::Schema.define(version: 2020_02_04_122030) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agames", force: :cascade do |t|
    t.integer "igdb_id"
    t.string "name"
    t.integer "first_release_date"
    t.text "summary"
    t.integer "status"
    t.integer "category"
    t.string "cover"
    t.integer "platforms", array: true
    t.string "platforms_names", array: true
    t.string "developers", array: true
    t.string "screenshots", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cover_width"
    t.integer "cover_height"
    t.integer "themes", array: true
    t.integer "platforms_categories", array: true
    t.index ["igdb_id"], name: "index_agames_on_igdb_id", unique: true
  end

  create_table "collection_games", force: :cascade do |t|
    t.bigint "collection_id"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id", "game_id", "created_at"], name: "by_coll_game_created_at"
    t.index ["collection_id", "game_id"], name: "index_collection_games_on_collection_id_and_game_id", unique: true
    t.index ["collection_id"], name: "index_collection_games_on_collection_id"
    t.index ["game_id"], name: "index_collection_games_on_game_id"
  end

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "needs_platform", default: false
    t.integer "cord"
    t.index ["cord"], name: "index_collections_on_cord"
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "developer_games", force: :cascade do |t|
    t.bigint "developer_id"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["developer_id", "game_id"], name: "index_developer_games_on_developer_id_and_game_id", unique: true
    t.index ["developer_id"], name: "index_developer_games_on_developer_id"
    t.index ["game_id"], name: "index_developer_games_on_game_id"
  end

  create_table "developers", force: :cascade do |t|
    t.string "name"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.integer "first_release_date"
    t.text "summary"
    t.integer "status"
    t.integer "category"
    t.integer "igdb_id"
    t.integer "platforms", array: true
    t.integer "platform"
    t.string "platform_name"
    t.boolean "physical"
    t.boolean "needs_platform", default: false
    t.string "cover"
    t.string "screenshots", array: true
    t.integer "cover_width"
    t.integer "cover_height"
    t.string "platforms_names", array: true
    t.index ["igdb_id", "needs_platform"], name: "index_games_on_igdb_id_and_needs_platform"
    t.index ["igdb_id", "platform", "physical"], name: "index_games_on_igdb_id_and_platform_and_physical", unique: true
    t.index ["igdb_id"], name: "index_games_on_igdb_id", unique: true, where: "((platform IS NULL) AND (physical IS NULL))"
  end

  create_table "platforms", force: :cascade do |t|
    t.integer "igdb_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["igdb_id"], name: "index_platforms_on_igdb_id", unique: true
  end

  create_table "queries", force: :cascade do |t|
    t.string "endpoint"
    t.string "body"
    t.integer "results", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "addl", array: true
    t.integer "response"
    t.index ["endpoint", "body"], name: "index_queries_on_endpoint_and_body", unique: true
  end

  create_table "records", force: :cascade do |t|
    t.string "inquiry"
    t.string "query_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "filters", array: true
    t.bigint "user_id"
    t.integer "results"
    t.boolean "custom_filters"
    t.index ["user_id"], name: "index_records_on_user_id"
  end

  create_table "shares", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token"
    t.integer "shared", array: true
    t.integer "times_visited", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "message"
    t.index ["token"], name: "index_shares_on_token", unique: true
    t.index ["user_id"], name: "index_shares_on_user_id"
  end

  create_table "user_platforms", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "platform_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform_id", "user_id"], name: "index_user_platforms_on_platform_id_and_user_id", unique: true
    t.index ["platform_id"], name: "index_user_platforms_on_platform_id"
    t.index ["user_id"], name: "index_user_platforms_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "games_per_view", default: 30
    t.string "remember_digest"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "collections", "users"
  add_foreign_key "records", "users"
end
