class AddSuggestedEditorToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :suggested_editor, :string
  end
end
