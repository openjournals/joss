class ChangeDefaultPaperCount < ActiveRecord::Migration[6.1]
  def change
    change_column_default :editors, :max_assignments, from: 2, to: 4 
  end
end
