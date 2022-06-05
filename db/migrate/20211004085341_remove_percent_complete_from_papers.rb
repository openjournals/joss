class RemovePercentCompleteFromPapers < ActiveRecord::Migration[6.1]
  def change
    remove_column :papers, :percent_complete, :float, default: 0.0
  end
end
