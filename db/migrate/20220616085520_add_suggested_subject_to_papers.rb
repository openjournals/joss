class AddSuggestedSubjectToPapers < ActiveRecord::Migration[7.0]
  def change
    add_column :papers, :suggested_subject, :string
  end
end
