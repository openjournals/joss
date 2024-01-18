class AddStartDateToEditors < ActiveRecord::Migration[7.1]
  def change
    add_column :editors, :buddy_id, :integer
    add_index :editors, :buddy_id
  end
end
