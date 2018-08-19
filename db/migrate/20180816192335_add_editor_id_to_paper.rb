class AddEditorIdToPaper < ActiveRecord::Migration[5.1]
  def change
    add_column :editors, :user_id, :integer
    add_column :papers, :editor_id, :integer
    add_column :papers, :reviewers, :string, array: true, default: []
  end
end
