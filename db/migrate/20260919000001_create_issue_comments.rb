class CreateIssueComments < ActiveRecord::Migration[7.2]
  def change
    create_table :issue_comments do |t|
      t.references :paper, null: false, foreign_key: true
      t.string :login, null: false
      t.integer :issue_id, null: false
      t.string :kind, null: false
      t.string :role, null: false
      t.string :comment_url
      t.datetime :commented_at, null: false

      t.timestamps
    end

    add_index :issue_comments, [:login, :commented_at]
    add_index :issue_comments, :commented_at
  end
end
