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

ActiveRecord::Schema.define(version: 20181213123534) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "editors", id: :serial, force: :cascade do |t|
    t.string "kind", default: "topic", null: false
    t.string "title"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "login", null: false
    t.string "email"
    t.string "avatar_url"
    t.string "categories", default: [], array: true
    t.string "url"
    t.string "description", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_editors_on_user_id"
  end

  create_table "papers", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "state"
    t.string "repository_url"
    t.string "archive_doi"
    t.string "sha"
    t.text "body"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "review_issue_id"
    t.string "software_version"
    t.string "doi"
    t.text "paper_body"
    t.integer "meta_review_issue_id"
    t.string "suggested_editor"
    t.text "authors"
    t.text "citation_string"
    t.datetime "accepted_at"
    t.string "kind"
    t.integer "editor_id"
    t.string "reviewers", default: [], array: true
    t.text "activities"
    t.datetime "last_activity"
    t.index ["editor_id"], name: "index_papers_on_editor_id"
    t.index ["last_activity"], name: "index_papers_on_last_activity"
    t.index ["reviewers"], name: "index_papers_on_reviewers", using: :gin
    t.index ["sha"], name: "index_papers_on_sha"
    t.index ["user_id"], name: "index_papers_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "oauth_token"
    t.string "oauth_expires_at"
    t.string "email"
    t.string "sha"
    t.hstore "extra"
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_username"
    t.index ["email"], name: "index_users_on_email"
    t.index ["name"], name: "index_users_on_name"
    t.index ["sha"], name: "index_users_on_sha"
  end

end
