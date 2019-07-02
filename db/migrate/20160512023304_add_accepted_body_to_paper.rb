class AddAcceptedBodyToPaper < ActiveRecord::Migration[5.2]
  def change
    add_column :papers, :paper_body, :text
  end
end
