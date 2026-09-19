class AeicDashboardController < ApplicationController
  before_action :require_aeic

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

  # Leaderboard of non-editor accounts by number of distinct issues commented
  # on in a time window. Useful to spot spammy "I can review" offers.
  def activity
    @track = Track.find(params[:track_id]) if params[:track_id].present?
    @days = IssueComment::WINDOWS.include?(params[:days].to_i) ? params[:days].to_i : IssueComment::DEFAULT_WINDOW
    since = @days.days.ago

    @leaderboard = IssueComment.leaderboard(since: since, track_id: @track&.id)

    if params[:login].present?
      @login = params[:login]
      comments_scope = IssueComment.since(since).for_login(@login).includes(:paper)
      comments_scope = comments_scope.by_track(@track.id) if @track.present?
      @login_comments = comments_scope.order(commented_at: :desc)
    end
  end

end
