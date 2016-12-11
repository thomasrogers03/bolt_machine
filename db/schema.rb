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

ActiveRecord::Schema.define(version: 20161210223417) do

  create_table "job_scripts", force: true do |t|
    t.integer  "job_id"
    t.string   "script"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", force: true do |t|
    t.string   "cron"
    t.string   "job_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "node_definitions", force: true do |t|
    t.string   "name"
    t.string   "script"
    t.string   "meta_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
