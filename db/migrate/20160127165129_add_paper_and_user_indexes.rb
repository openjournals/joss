class AddPaperAndUserIndexes < ActiveRecord::Migration
  def change
    add_index :users, :sha
    add_index :users, :email
    add_index :users, :name

    add_index :papers, :user_id
    add_index :papers, :sha
  end
end
