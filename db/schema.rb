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

ActiveRecord::Schema[7.2].define(version: 2025_08_07_235919) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.string "summary"
    t.text "content"
    t.string "sources"
    t.bigint "category_id", null: false
    t.string "image"
    t.float "sentiment_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "feed_entry_id", null: false
    t.index ["category_id"], name: "index_articles_on_category_id"
    t.index ["feed_entry_id"], name: "index_articles_on_feed_entry_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.bigint "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string "title"
    t.string "link"
    t.bigint "meeting_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meeting_id"], name: "index_documents_on_meeting_id"
  end

  create_table "feed_entries", force: :cascade do |t|
    t.bigint "feed_id", null: false
    t.bigint "category_id", null: false
    t.string "guid", null: false
    t.string "title"
    t.string "summary"
    t.string "url"
    t.string "image"
    t.text "content", null: false
    t.float "sentiment_score", null: false
    t.integer "generation_edict", default: 0, null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_feed_entries_on_category_id"
    t.index ["feed_id", "guid", "url"], name: "index_feed_entries_on_feed_id_and_guid_and_url", unique: true
    t.index ["feed_id"], name: "index_feed_entries_on_feed_id"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "url", null: false
    t.string "name", null: false
    t.string "content_selector"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_feeds_on_category_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.string "title"
    t.string "external_id"
    t.string "location"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_meetings_on_external_id", unique: true
  end

  create_table "transcripts", force: :cascade do |t|
    t.text "content"
    t.string "external_id"
    t.integer "pipeline", default: 0, null: false
    t.bigint "video_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_transcripts_on_external_id", unique: true
    t.index ["video_id"], name: "index_transcripts_on_video_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.string "title"
    t.string "link"
    t.string "external_id"
    t.integer "pipeline", default: 0, null: false
    t.bigint "meeting_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_videos_on_external_id", unique: true
    t.index ["meeting_id"], name: "index_videos_on_meeting_id"
  end

  add_foreign_key "articles", "categories"
  add_foreign_key "articles", "feed_entries"
  add_foreign_key "documents", "meetings"
  add_foreign_key "feed_entries", "categories"
  add_foreign_key "feed_entries", "feeds"
  add_foreign_key "feeds", "categories"
  add_foreign_key "transcripts", "videos"
  add_foreign_key "videos", "meetings"
end
