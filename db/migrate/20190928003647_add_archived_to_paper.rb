class AddArchivedToPaper < ActiveRecord::Migration[6.0]
  def change
    add_column :papers, :archived, :boolean, default: false
  end
end
