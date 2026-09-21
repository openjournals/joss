class CreateBlocklistEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :blocklist_entries do |t|
      t.string :kind, null: false
      t.string :value, null: false
      t.text :reason
      t.references :editor, foreign_key: true

      t.timestamps
    end

    add_index :blocklist_entries, [:kind, :value], unique: true
  end
end
