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

ActiveRecord::Schema.define(version: 20160501153524) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "pgcrypto"

  create_table "cards", force: :cascade do |t|
    t.string   "payment_token",                 null: false
    t.integer  "user_id",                       null: false
    t.string   "brand"
    t.string   "last4"
    t.integer  "exp_month"
    t.integer  "exp_year"
    t.string   "name"
    t.boolean  "default",       default: false, null: false
    t.boolean  "archived",      default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "charges", force: :cascade do |t|
    t.string   "payment_token",                   null: false
    t.integer  "subscription_id",                 null: false
    t.integer  "card_id",                         null: false
    t.integer  "amount",          default: 0,     null: false
    t.boolean  "paid",            default: false, null: false
    t.string   "failure_code"
    t.string   "failure_message"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "forms", force: :cascade do |t|
    t.string   "uid",                               null: false
    t.string   "name",                              null: false
    t.string   "redirect_url"
    t.boolean  "email",             default: false, null: false
    t.integer  "user_id",                           null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "additional_emails", default: [],                 array: true
  end

  add_index "forms", ["additional_emails"], name: "index_forms_on_additional_emails", using: :gin
  add_index "forms", ["uid"], name: "index_forms_on_uid", unique: true, using: :btree

  create_table "plans", force: :cascade do |t|
    t.string   "name",                              null: false
    t.string   "description",                       null: false
    t.integer  "price",             default: 0,     null: false
    t.integer  "form_quota",                        null: false
    t.integer  "trial_period_days", default: 30,    null: false
    t.integer  "sort",                              null: false
    t.boolean  "default",           default: false, null: false
    t.boolean  "archived",          default: false, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "plans", ["name"], name: "index_plans_on_name", unique: true, using: :btree

  create_table "que_jobs", primary_key: ["queue", "priority", "run_at", "job_id"], force: :cascade do |t|
    t.integer   "priority",    limit: 2, default: 100,            null: false
    t.datetime  "run_at",                default: -> { "now()" }, null: false
    t.bigserial "job_id",      limit: 8,                          null: false
    t.text      "job_class",                                      null: false
    t.json      "args",                  default: [],             null: false
    t.integer   "error_count",           default: 0,              null: false
    t.text      "last_error"
    t.text      "queue",                 default: "",             null: false
  end

  create_table "refunds", force: :cascade do |t|
    t.string   "payment_token",             null: false
    t.integer  "charge_id",                 null: false
    t.integer  "amount",        default: 0, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.integer  "form_id",    null: false
    t.json     "payload"
    t.json     "headers"
    t.boolean  "spam"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id",                              null: false
    t.integer  "plan_id",                              null: false
    t.integer  "status",               default: 0,     null: false
    t.boolean  "cancel_at_period_end", default: false, null: false
    t.datetime "period_start",                         null: false
    t.datetime "period_end"
    t.datetime "canceled_at"
    t.datetime "ended_at"
    t.boolean  "archived",             default: false, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                  null: false
    t.string   "password_digest",             limit: 60, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "password_reset_token"
    t.datetime "password_reset_requested_at"
    t.string   "payment_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true, using: :btree

  add_foreign_key "cards", "users"
  add_foreign_key "charges", "cards"
  add_foreign_key "charges", "subscriptions"
  add_foreign_key "forms", "users"
  add_foreign_key "refunds", "charges"
  add_foreign_key "submissions", "forms"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "subscriptions", "users"
end
