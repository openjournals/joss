class AddGitBranchToPapers < ActiveRecord::Migration[6.1]
  def change
    add_column :papers, :git_branch, :string
  end
end
