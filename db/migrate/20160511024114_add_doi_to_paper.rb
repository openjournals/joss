class AddDoiToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :doi, :string
  end
end
