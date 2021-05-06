class InvitationsController < ApplicationController
  before_action :require_admin_user

  def index
    @invitations = Invitation.includes(:editor, :paper).
                              order(created_at: :desc).
                              paginate(page: params[:page], per_page: 25)
  end

  def expire
    @invitation = Invitation.pending.find(params[:id])
    @invitation.expire! if @invitation
    redirect_to invitations_path(page: params[:page].presence), notice: "Invitation canceled!"
  end
end
