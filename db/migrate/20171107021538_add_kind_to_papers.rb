class AddKindToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :kind, :string
  end
end
