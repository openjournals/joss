class AddLastActiveAtToPapers < ActiveRecord::Migration[5.1]
  def change
    add_column :papers, :last_activity, :datetime
    add_index :papers, :last_activity
  end
end
