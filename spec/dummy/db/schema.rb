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

ActiveRecord::Schema.define(version: 20160228132543) do

  create_table "social_framework_edge_relationships", force: :cascade do |t|
    t.integer "edge_id"
    t.integer "relationship_id"
    t.boolean "active"
  end

  add_index "social_framework_edge_relationships", ["edge_id", "relationship_id"], name: "edges_and_relationships_unique", unique: true
  add_index "social_framework_edge_relationships", ["edge_id"], name: "index_social_framework_edge_relationships_on_edge_id"
  add_index "social_framework_edge_relationships", ["relationship_id"], name: "index_social_framework_edge_relationships_on_relationship_id"

  create_table "social_framework_edges", force: :cascade do |t|
    t.integer  "origin_id"
    t.integer  "destiny_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "social_framework_edges", ["destiny_id"], name: "index_social_framework_edges_on_destiny_id"
  add_index "social_framework_edges", ["origin_id"], name: "index_social_framework_edges_on_origin_id"

  create_table "social_framework_relationships", force: :cascade do |t|
    t.string   "label",      default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "social_framework_relationships", ["label"], name: "index_social_framework_relationships_on_label", unique: true

  create_table "social_framework_users", force: :cascade do |t|
    t.string   "username",               default: "", null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "social_framework_users", ["email"], name: "index_social_framework_users_on_email", unique: true
  add_index "social_framework_users", ["reset_password_token"], name: "index_social_framework_users_on_reset_password_token", unique: true
  add_index "social_framework_users", ["username"], name: "index_social_framework_users_on_username", unique: true

end
