class AddPaperMetadata < ActiveRecord::Migration
  def change
    add_column :papers, :authors, :text
    add_column :papers, :citation_string, :text
    add_column :papers, :accepted_at, :datetime
  end
end
