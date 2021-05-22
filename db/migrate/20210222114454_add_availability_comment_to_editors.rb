class AddAvailabilityCommentToEditors < ActiveRecord::Migration[6.1]
  def change
    add_column :editors, :availability_comment, :string
  end
end
