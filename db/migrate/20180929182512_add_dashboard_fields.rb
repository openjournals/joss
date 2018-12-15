class AddDashboardFields < ActiveRecord::Migration[5.1]
  def change
    add_column :papers, :activities, :text
  end
end
