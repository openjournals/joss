class AddStateToInvitations < ActiveRecord::Migration[6.1]
  def change
    add_column :invitations, :state, :string, default: 'pending'

    migrate_state

    remove_column :invitations, :accepted

    add_index :invitations, :state
  end

  def migrate_state
    Invitation.includes(:paper).in_batches.each_record do |invitation|
      if invitation.accepted == true
        invitation.update_attribute(:state, 'accepted')
      elsif invitation.paper.editor_id.present? && invitation.paper.editor_id != invitation.editor_id
        invitation.update_attribute(:state, 'expired')
      end

      # If migration is rollbacked:
      invitation.update_attribute(:accepted, true) if invitation.state == 'accepted'
    end
  end
end
