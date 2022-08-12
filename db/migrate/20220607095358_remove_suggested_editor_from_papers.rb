class RemoveSuggestedEditorFromPapers < ActiveRecord::Migration[7.0]
  def change
    remove_column :papers, :suggested_editor, :string
  end
end
