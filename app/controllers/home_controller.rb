class HomeController < ApplicationController
  before_action :require_user, only: %w(profile update_profile)
  before_action :require_editor, only: %w(dashboard reviews incoming stats all in_progress)
  before_action :set_track, only: %w(all incoming in_progress query_scoped)
  # layout "dashboard", only:  %w(dashboard reviews incoming stats all in_progress)

  def index
    @papers = Paper.unscoped.visible.order(accepted_at: :desc).limit(10)
  end

  def about
  end

  def dashboard
    if params[:editor]
      @editor = Editor.find_by_login(params[:editor])
    else
      @editor = current_user.editor
    end

    @reviewer = params[:reviewer].nil? ? "@arfon" : params[:reviewer]
    @reviewer_papers = Paper.unscoped.where(":reviewer = ANY(reviewers)", reviewer: @reviewer).group_by_month(:accepted_at).count

    @accepted_papers = Paper.unscoped.visible.group_by_month(:accepted_at).count
    @editor_papers = Paper.unscoped.where(editor: @editor).visible.group_by_month(:accepted_at).count

    @assignment_by_editor = Paper.unscoped.in_progress.group(:editor_id).count
    @paused_by_editor = Paper.unscoped.in_progress.where("labels->>'paused' ILIKE '%'").group(:editor_id).count

    @papers_last_week = Paper.unscoped.visible.since(1.week.ago).group(:editor_id).count
    @papers_last_month = Paper.unscoped.visible.since(1.month.ago).group(:editor_id).count
    @papers_last_3_months = Paper.unscoped.visible.since(3.months.ago).group(:editor_id).count
    @papers_last_year = Paper.unscoped.visible.since(1.year.ago).group(:editor_id).count
    @papers_all_time = Paper.unscoped.visible.since(100.year.ago).group(:editor_id).count
  end

  def reviews
    sort = "complete"
    case params[:order]
    when "complete-desc"
      @order = "desc"
    when "complete-asc"
      @order = "asc"
    when "active-desc"
      @order = "desc"
      sort = "active"
    when "active-asc"
      @order = "asc"
      sort = "active"
    when nil
      @order = "desc"
    else
      @order = "desc"
    end

    if params[:editor]
      @editor = Editor.find_by_login(params[:editor])

      if sort == "active"
        @pagy, @papers = pagy(Paper.unscoped.in_progress.where(editor: @editor).order(last_activity: @order))
      else
        @pagy, @papers = pagy(Paper.unscoped.in_progress.where(editor: @editor).order(created_at: @order))
      end
    else
      @pagy, @papers = pagy(Paper.everything)
    end
  end

  def incoming
    incoming_scope = Paper.unscoped.in_progress.where(editor: nil)
    incoming_scope = incoming_scope.by_track(@track.id) if @track.present?

    @order = params[:order].to_s.end_with?("-asc") ? "asc" : "desc"

    if params[:order].to_s.include?("active-")
      @pagy, @papers = pagy(incoming_scope.order(last_activity: @order))
    else
      @pagy, @papers = pagy(incoming_scope.order(created_at: @order))
    end

    @editor = current_user.editor
    set_votes_by_paper_from_editor(@editor, @papers)
    load_pending_invitations_for_papers(@papers)

    render template: "home/reviews"
  end

  def in_progress
    in_progress_scope = Paper.unscoped.in_progress
    in_progress_scope = in_progress_scope.by_track(@track.id) if @track.present?

    @editor = current_user.editor
    @order = params[:order].to_s.end_with?("-asc") ? "asc" : "desc"

    if params[:order].to_s.include?("active-")
      @pagy, @papers = pagy(in_progress_scope.order(last_activity: @order))
    else
      @pagy, @papers = pagy(in_progress_scope.order(created_at: @order))
    end

    set_votes_by_paper_from_editor(@editor, @papers)
    load_pending_invitations_for_papers(@papers)

    render template: "home/reviews"
  end

  def query_scoped
    in_progress_query_scoped = Paper.unscoped.in_progress.query_scoped
    in_progress_query_scoped = in_progress_query_scoped.by_track(@track.id) if @track.present?

    @editor = current_user.editor
    @order = params[:order].to_s.end_with?("-asc") ? "asc" : "desc"

    if params[:order].to_s.include?("active-")
      @pagy, @papers = pagy(in_progress_query_scoped.order(last_activity: @order))
    else
      @pagy, @papers = pagy(in_progress_query_scoped.order(created_at: @order))
    end

    set_votes_by_paper_from_editor(@editor, @papers)
    load_pending_invitations_for_papers(@papers)

    render template: "home/reviews"
  end

  def all
    all_scope = Paper.unscoped.all
    all_scope = Paper.unscoped.by_track(@track.id) if @track.present?

    @editor = current_user.editor
    @order = params[:order].to_s.end_with?("-asc") ? "asc" : "desc"

    if params[:order].to_s.include?("active-")
      @pagy, @papers = pagy(all_scope.order(last_activity: @order))
    else
      @pagy, @papers = pagy(all_scope.order(created_at: @order))
    end

    set_votes_by_paper_from_editor(@editor, @papers)
    load_pending_invitations_for_papers(@papers)

    render template: "home/reviews"
  end

  def update_profile
    check_github_username

    if current_user.update(user_params)
      redirect_back(notice: "Profile updated", fallback_location: root_path)
    end
  end

  def profile
    @user = current_user
  end

private

  def check_github_username
    if user_params.has_key?('github_username')
      if !user_params['github_username'].strip.start_with?('@')
        old = user_params['github_username']
        user_params['github_username'] = old.prepend('@')
      end
    end
  end

  def user_params
    params.require(:user).permit(:email, :github_username)
  end

  def load_pending_invitations_for_papers(papers)
    @pending_invitations = Invitation.includes(:editor).pending.where(paper: papers)
  end

  def set_track
    @track = Track.find(params[:track_id]) if params[:track_id].present?
  end

  def set_votes_by_paper_from_editor(editor, papers)
    in_scope_papers = papers.select {|p| p.labels.keys.include?("query-scope")}
    @votes_by_paper_from_editor = in_scope_papers.any? ? Vote.where(editor: editor).where(paper: in_scope_papers).index_by(&:paper_id) : {}
  end
end
