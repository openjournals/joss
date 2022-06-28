class InvitationsController < ApplicationController
  before_action :require_aeic
  before_action :set_track, only: [:index]

  def index
    invitations_scope = @track.present? ? Invitation.by_track(@track.id) : Invitation

    @invitations = invitations_scope.includes(:editor, :paper).
                              order(created_at: :desc).
                              paginate(page: params[:page], per_page: 25)
  end

  def expire
    @invitation = Invitation.pending.find(params[:id])
    @invitation.expire! if @invitation
    redirect_to invitations_path(page: params[:page].presence, track_id: params[:track_id].presence), notice: "Invitation canceled!"
  end

  private
    def set_track
      @track = Track.find(params[:track_id]) if params[:track_id].present?
    end
end
