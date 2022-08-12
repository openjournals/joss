class CreateTrackAeics < ActiveRecord::Migration[7.0]
  def change
    create_table :track_aeics do |t|
      t.bigint :track_id
      t.bigint :editor_id
      t.timestamps
    end
  end
end
