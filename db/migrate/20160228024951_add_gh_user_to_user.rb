class AddGhUserToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :github_username, :string
  end
end
