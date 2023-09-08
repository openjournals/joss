class InvitationsController < ApplicationController
  before_action :require_aeic
  before_action :set_track, only: [:index]

  def index
    invitations_scope = @track.present? ? Invitation.by_track(@track.id) : Invitation

    @pagy, @invitations = pagy(invitations_scope.includes(:editor, :paper).order(created_at: :desc), items: 25)
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
