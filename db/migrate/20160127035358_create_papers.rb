class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.string      :title
      t.string      :state
      t.string      :repository_url
      t.string      :archive_doi
      t.string      :sha
      t.text        :body
      t.column      :user_id, :integer
      t.timestamps  null: false
    end
  end
end
