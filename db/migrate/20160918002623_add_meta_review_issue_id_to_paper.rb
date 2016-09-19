class AddMetaReviewIssueIdToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :meta_review_issue_id, :integer
  end
end
