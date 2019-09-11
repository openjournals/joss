class AddMetadataToPaper < ActiveRecord::Migration[5.2]
  def change
    add_column :papers, :metadata, :text
  end
end
