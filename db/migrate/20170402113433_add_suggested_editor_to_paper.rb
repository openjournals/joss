class AddSuggestedEditorToPaper < ActiveRecord::Migration[5.2]
  def change
    add_column :papers, :suggested_editor, :string
  end
end
