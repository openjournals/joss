class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.column :editor_id, :integer
      t.column :paper_id, :integer
      t.column :comment, :text
      t.timestamps
    end

    add_index :notes, :editor_id
    add_index :notes, :paper_id
  end
end
