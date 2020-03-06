class AddSubmissionKindToPaper < ActiveRecord::Migration[6.0]
  def change
    add_column :papers, :submission_kind, :string

    # Migrate past papers
    Paper.all.each do |paper|
      paper.submission_kind = 'new'; paper.save
    end
  end
end
