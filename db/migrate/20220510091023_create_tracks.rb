class CreateTracks < ActiveRecord::Migration[7.0]
  def change
    create_table :tracks do |t|
      t.string :name
      t.string :short_name
      t.integer :code

      t.timestamps
    end

    add_reference :papers, :track
    create_join_table :editors, :tracks
  end
end
