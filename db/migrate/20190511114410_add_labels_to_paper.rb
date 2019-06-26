class AddLabelsToPaper < ActiveRecord::Migration[5.2]
  def change
    add_column :papers, :labels, :jsonb, null: false, default: {}
    add_index  :papers, :labels, using: 'gin'
  end
end
