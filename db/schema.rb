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

ActiveRecord::Schema.define(version: 2021_06_15_101009) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

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
    t.string "availability_comment"
    t.integer "max_assignments", default: 4, null: false
    t.index ["user_id"], name: "index_editors_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "editor_id"
    t.bigint "paper_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state", default: "pending"
    t.index ["created_at"], name: "index_invitations_on_created_at"
    t.index ["editor_id"], name: "index_invitations_on_editor_id"
    t.index ["paper_id"], name: "index_invitations_on_paper_id"
    t.index ["state"], name: "index_invitations_on_state"
  end

  create_table "notes", force: :cascade do |t|
    t.integer "editor_id"
    t.integer "paper_id"
    t.text "comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["editor_id"], name: "index_notes_on_editor_id"
    t.index ["paper_id"], name: "index_notes_on_paper_id"
  end

  create_table "onboarding_invitations", force: :cascade do |t|
    t.string "email"
    t.string "token"
    t.string "name"
    t.datetime "last_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "accepted_at"
    t.datetime "invited_to_team_at"
    t.bigint "editor_id"
    t.index ["editor_id"], name: "index_onboarding_invitations_on_editor_id"
    t.index ["token", "email"], name: "index_onboarding_invitations_on_token_and_email"
    t.index ["token"], name: "index_onboarding_invitations_on_token"
  end

  create_table "papers", force: :cascade do |t|
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
    t.string "kind"
    t.text "authors"
    t.text "citation_string"
    t.datetime "accepted_at"
    t.integer "editor_id"
    t.string "reviewers", default: [], array: true
    t.text "activities"
    t.datetime "last_activity"
    t.jsonb "labels", default: {}, null: false
    t.text "metadata"
    t.text "retraction_notice"
    t.boolean "archived", default: false
    t.integer "eic_id"
    t.string "submission_kind"
    t.float "percent_complete", default: 0.0
    t.index ["editor_id"], name: "index_papers_on_editor_id"
    t.index ["eic_id"], name: "index_papers_on_eic_id"
    t.index ["labels"], name: "index_papers_on_labels", using: :gin
    t.index ["last_activity"], name: "index_papers_on_last_activity"
    t.index ["percent_complete"], name: "index_papers_on_percent_complete"
    t.index ["reviewers"], name: "index_papers_on_reviewers", using: :gin
    t.index ["sha"], name: "index_papers_on_sha"
    t.index ["user_id"], name: "index_papers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
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

  create_table "votes", force: :cascade do |t|
    t.integer "editor_id"
    t.integer "paper_id"
    t.string "kind"
    t.text "comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["editor_id", "paper_id"], name: "index_votes_on_editor_id_and_paper_id", unique: true
    t.index ["editor_id"], name: "index_votes_on_editor_id"
    t.index ["kind"], name: "index_votes_on_kind"
    t.index ["paper_id"], name: "index_votes_on_paper_id"
  end

end
