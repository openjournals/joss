class CreateReviewers < ActiveRecord::Migration[7.2]
  def change
    create_table :reviewers do |t|
      t.string :github_username, null: false
      t.string :name
      t.string :email
      t.references :user, null: true, foreign_key: true
      t.timestamps
    end

    add_index :reviewers, :github_username, unique: true
    add_index :reviewers, :user_id, unique: true
  end
end
