class AddPercentCompleteToPaper < ActiveRecord::Migration[6.1]
  def change
    add_column :papers, :percent_complete, :float, default: 0.0
    add_index :papers, :percent_complete

    # Migrate past papers
    Paper.all.each do |paper|
      paper.submission_kind = 'new'; paper.save
    end
  end
end
