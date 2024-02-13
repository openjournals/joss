class AddIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :editors_tracks, :editor_id
    add_index :editors_tracks, :track_id

    add_index :tracks, :name

    add_index :track_aeics, :editor_id
    add_index :track_aeics, :track_id

    add_index :subjects, [:name, :track_id]
    add_index :subjects, :track_id
  end
end
