class AddManagingEditorToPaper < ActiveRecord::Migration[6.0]
  def change
    add_column :papers, :eic_id, :integer
    add_index :papers, :eic_id
  end
end
