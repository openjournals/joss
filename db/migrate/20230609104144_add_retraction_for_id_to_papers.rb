class AddRetractionForIdToPapers < ActiveRecord::Migration[7.0]
  def change
    add_reference :papers, :retraction_for, foreign_key: { to_table: :papers }, null: true
  end
end
