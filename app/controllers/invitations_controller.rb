class InvitationsController < ApplicationController
  before_action :require_admin_user

  def index
    @invitations = Invitation.includes(:editor, :paper).order(created_at: :desc).limit(25)
  end
end
