class AddDoiToPaper < ActiveRecord::Migration[5.2]
  def change
    add_column :papers, :doi, :string
  end
end
