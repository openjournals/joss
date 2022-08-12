class AeicDashboardController < ApplicationController
  before_action :require_admin_user

  def index
    if params[:track_id].present?
      @track = Track.find(params[:track_id])
      recommend_accept_labels = ["recommend-accept", @track.label].compact.join(",")
      query_scope_labels = ["query-scope", @track.label].compact.join(",")
    else
      params[:track_id] = nil
      recommend_accept_labels = "recommend-accept"
      query_scope_labels = "query-scope"
    end

    @recommend_accept = GITHUB.issues(Rails.application.settings["reviews"], labels: recommend_accept_labels, state:"open")
    @with_query_scope = GITHUB.issues(Rails.application.settings["reviews"], labels: query_scope_labels, state:"open")
  end

end
