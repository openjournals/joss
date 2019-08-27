class AddSoftwareVersionToPaper < ActiveRecord::Migration[5.2]
  def change
    add_column :papers, :software_version, :string
  end
end
