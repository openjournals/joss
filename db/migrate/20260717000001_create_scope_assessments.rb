class CreateScopeAssessments < ActiveRecord::Migration[7.2]
  def change
    create_table :scope_assessments do |t|
      t.references :paper, null: false, foreign_key: true
      t.jsonb :computed_signals, default: {}, null: false  # the RepoInfo blob (L0)
      t.jsonb :gates, default: {}, null: false             # tri-state gate results + notes + triggers (L1)
      t.string :recommendation                             # PROCEED | DESK_REJECT | REQUIRES_VERIFICATION | BORDERLINE_* | NEEDS_MANUAL
      t.string :tier_reached                               # L0 | L1 | L2 | L3
      t.jsonb :evidence_trail, default: [], null: false    # L3: endpoints fetched + findings
      t.text :draft_note                                   # author-facing draft for the EiC to edit
      t.text :summary                                      # model narrative for the EiC
      t.jsonb :model_versions, default: {}, null: false    # which model produced which tier
      t.string :status, default: "pending", null: false    # pending | approved | overridden | needs_manual | error
      t.string :repo_head_sha                              # for staleness / re-run detection
      t.text :error_message
      t.references :decided_by, foreign_key: { to_table: :editors }
      t.datetime :decided_at

      t.timestamps
    end

    add_index :scope_assessments, :status
    add_index :scope_assessments, :recommendation
    add_index :scope_assessments, [:paper_id, :created_at]
  end
end
