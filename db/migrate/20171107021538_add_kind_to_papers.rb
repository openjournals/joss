class AddKindToPapers < ActiveRecord::Migration[5.0]
  def change
    add_column :papers, :kind, :string
  end
end
