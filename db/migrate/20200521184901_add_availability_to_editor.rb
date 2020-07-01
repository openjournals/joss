class AddAvailabilityToEditor < ActiveRecord::Migration[6.0]
  def change
    add_column :editors, :availability, :string
    add_index :editors, :availability
  end
end