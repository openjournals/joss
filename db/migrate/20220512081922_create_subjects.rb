class CreateSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :subjects do |t|
      t.string :name
      t.bigint :track_id

      t.timestamps
    end
  end
end
