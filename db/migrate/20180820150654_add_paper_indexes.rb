class AddPaperIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :editors, :user_id
    add_index :papers, :editor_id
    add_index :papers, :reviewers, using: 'gin'
  end
end
