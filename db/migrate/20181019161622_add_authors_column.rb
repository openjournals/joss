class AddAuthorsColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :papers, :authors, :text
  end
end
