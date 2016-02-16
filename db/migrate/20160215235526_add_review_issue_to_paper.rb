class AddReviewIssueToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :review_issue_id, :integer
  end
end
