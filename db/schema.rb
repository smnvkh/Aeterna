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

ActiveRecord::Schema[8.1].define(version: 2025_12_04_124259) do
  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "memory_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["memory_id"], name: "index_comments_on_memory_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "families", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "family_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "family_id", null: false
    t.integer "father_id"
    t.string "gender"
    t.integer "mother_id"
    t.string "name"
    t.string "relation"
    t.integer "spouse_id"
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_family_members_on_family_id"
  end

  create_table "memories", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "family_id", null: false
    t.integer "family_member_id"
    t.string "image"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_memories_on_family_id"
    t.index ["family_member_id"], name: "index_memories_on_family_member_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "family_id", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["family_id"], name: "index_users_on_family_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "comments", "memories"
  add_foreign_key "comments", "users"
  add_foreign_key "family_members", "families"
  add_foreign_key "memories", "families"
  add_foreign_key "memories", "family_members"
  add_foreign_key "users", "families"
end
