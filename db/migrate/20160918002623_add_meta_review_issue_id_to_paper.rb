class AddMetaReviewIssueIdToPaper < ActiveRecord::Migration[5.2]
  def change
    add_column :papers, :meta_review_issue_id, :integer
  end
end
