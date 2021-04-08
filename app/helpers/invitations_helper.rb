module InvitationsHelper
  def invitation_status(invitation)
    status = "⏳ Pending"

    if invitation.accepted?
      status = "✅ Accepted"
    elsif invitation.paper.review_issue_id.present? &&
          invitation.paper.editor_id != invitation.editor_id
      status = "❌ Rejected"
    end

    status
  end
end
