class CreateInvitations < ActiveRecord::Migration[6.1]
  def change
    create_table :invitations do |t|
      t.belongs_to :editor
      t.belongs_to :paper
      t.boolean :accepted, default: false
      t.timestamps
    end

    add_index :invitations, :created_at
  end
end
