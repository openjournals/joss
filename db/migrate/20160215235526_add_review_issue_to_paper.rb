class AddReviewIssueToPaper < ActiveRecord::Migration[5.2]
  def change
    add_column :papers, :review_issue_id, :integer
  end
end
