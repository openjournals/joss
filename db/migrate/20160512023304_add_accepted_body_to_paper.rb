class AddAcceptedBodyToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :paper_body, :text
  end
end
