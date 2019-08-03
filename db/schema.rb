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

ActiveRecord::Schema.define(version: 2019_08_02_192218) do

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
    t.index ["igdb_id"], name: "index_agames_on_igdb_id"
  end

  create_table "collection_games", force: :cascade do |t|
    t.bigint "collection_id"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id", "game_id"], name: "index_collection_games_on_collection_id_and_game_id", unique: true
    t.index ["collection_id"], name: "index_collection_games_on_collection_id"
    t.index ["game_id"], name: "index_collection_games_on_game_id"
  end

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.boolean "default"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "custom_name"
    t.boolean "needs_platform", default: false
    t.string "form", default: "custom"
    t.boolean "initial", default: false
    t.index ["initial"], name: "index_collections_on_initial"
    t.index ["user_id"], name: "index_collections_on_user_id"
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
    t.boolean "needs_platform"
    t.string "developers", array: true
    t.string "cover"
    t.string "screenshots", array: true
    t.integer "cover_width"
    t.integer "cover_height"
    t.string "platforms_names", array: true
    t.index ["igdb_id"], name: "index_games_on_igdb_id"
  end

  create_table "queries", force: :cascade do |t|
    t.string "endpoint"
    t.string "body"
    t.integer "results", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "addl", array: true
    t.integer "response"
    t.index ["body"], name: "index_queries_on_body"
    t.index ["endpoint"], name: "index_queries_on_endpoint"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "collections", "users"
end
