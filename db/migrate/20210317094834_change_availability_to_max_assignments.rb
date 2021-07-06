class ChangeAvailabilityToMaxAssignments < ActiveRecord::Migration[6.1]
  def change
    add_column :editors, :max_assignments, :integer, null: false, default: 2
    migrate_availability
    remove_column :editors, :availability, :string
  end

  def migrate_availability
    if Editor.first.respond_to?(:max_assignments) && Editor.first.respond_to?(:availability)
      map_by_current_availability = { "available" => 2,
                                      "somewhat" => 1,
                                      "none" => 0,
                                      "" => 2,
                                      nil => 2 }
      assigned_by_editor = Paper.unscoped.in_progress.group(:editor_id).count
      Editor.emeritus.update_all(max_assignments: 0)
      Editor.active.each do |editor|
        editor.max_assignments = map_by_current_availability[editor.availability]
        editor.save
      end
    end
  end
end
