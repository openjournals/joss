class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.string      :title
      t.string      :state
      t.string      :repository_url
      t.string      :archive_doi
      t.text        :body
      t.timestamps null: false
    end
  end
end
