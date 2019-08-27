class AddPaperMetadata < ActiveRecord::Migration[5.2]
  def change
    add_column :papers, :authors, :text
    add_column :papers, :citation_string, :text
    add_column :papers, :accepted_at, :datetime
  end
end
