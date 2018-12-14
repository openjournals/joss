class HomeController < ApplicationController
  before_action :require_user, :only => %w(profile update_profile)
  before_action :require_editor, :only => %w(dashboard reviews incoming stats all in_progress)
  layout "dashboard", :only =>  %w(dashboard reviews incoming stats all in_progress)

  def index
    @papers = Paper.visible.limit(10)
  end

  def about
  end

  def dashboard
    if params[:editor]
      @editor = Editor.find_by_login(params[:editor])
    else
      @editor = Editor.first
    end

    @reviewer = params[:reviewer].nil? ? "@arfon" : params[:reviewer]
    @reviewer_papers = Paper.unscoped.where(":reviewer = ANY(reviewers)", reviewer: @reviewer).group_by_month(:accepted_at).count

    @accepted_papers = Paper.unscoped.visible.group_by_month(:accepted_at).count
    @editor_papers = Paper.unscoped.where(:editor => @editor).visible.group_by_month(:accepted_at).count
  end

  def incoming
    if params[:order]
      @papers = Paper.unscoped.in_progress.where(:editor => nil).order(:last_activity => params[:order]).paginate(
                  :page => params[:page],
                  :per_page => 20
                )
    else
      @papers = Paper.in_progress.where(:editor => nil).paginate(
                  :page => params[:page],
                  :per_page => 20
                )
    end

    @active_tab = "incoming"

    render template: "home/reviews"
  end

  def reviews
    if params[:editor]
      @active_tab = @editor = Editor.find_by_login(params[:editor])
      sort_order = params[:order] ? params[:order] : 'desc'

      @papers = Paper.unscoped.in_progress.where(:editor => @editor).order(:last_activity => sort_order).paginate(
                  :page => params[:page],
                  :per_page => 20
                )
    else
      @papers = Paper.everything.paginate(
                  :page => params[:page],
                  :per_page => 20
                )
    end
  end

  def in_progress
    if params[:order]
      @papers = Paper.unscoped.in_progress.order(:last_activity => params[:order]).paginate(
                  :page => params[:page],
                  :per_page => 20
                )
    else
      @papers = Paper.in_progress.paginate(
                  :page => params[:page],
                  :per_page => 20
                )
    end
    render template: "home/reviews"
  end

  def all
    if params[:order]
      @papers = Paper.unscoped.all.order(:last_activity => params[:order]).paginate(
                :page => params[:page],
                :per_page => 20
              )
    else
      @papers = Paper.all.paginate(
                :page => params[:page],
                :per_page => 20
              )
    end
    
    render template: "home/reviews"
  end

  def update_profile
    check_github_username

    if current_user.update_attributes(user_params)
      redirect_back(:notice => "Profile updated", :fallback_location => root_path)
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
end
