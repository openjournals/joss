class AddSoftwareVersionToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :software_version, :string
  end
end
