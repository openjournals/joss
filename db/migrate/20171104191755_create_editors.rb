class CreateEditors < ActiveRecord::Migration[5.0]
  def change
    create_table :editors do |t|
      t.string :kind, null: false, default: "topic"
      t.string :title
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :login, null: false
      t.string :email
      t.string :avatar_url
      t.string :categories, array: true, default: []
      t.string :url
      t.string :description, default: ""

      t.timestamps null: false
    end
  end
end
