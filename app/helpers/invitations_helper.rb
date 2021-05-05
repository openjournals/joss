module InvitationsHelper
  def invitation_status(invitation)
    status = "⏳ Pending"

    if invitation.accepted?
      status = "✅ Accepted"
    elsif invitation.expired?
      status = "❌ Expired"
    end

    status
  end
end
