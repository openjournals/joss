class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.column      :editor_id, :integer
      t.column      :paper_id, :integer
      t.column      :kind, :string
      t.column      :comment, :text
      t.timestamps
    end

    add_index :votes, :editor_id
    add_index :votes, :paper_id
    add_index :votes, :kind
    add_index :votes, [:editor_id, :paper_id], unique: true
  end
end
