class HomeController < ApplicationController
  before_action :require_user, :only => %w(profile update_profile)
  before_action :require_editor, :only => %w(dashboard)

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

    @accepted_papers = Paper.unscoped.visible.group_by_month(:accepted_at).count
    @editor_papers = Paper.unscoped.where(:editor => @editor).visible.group_by_month(:accepted_at).count
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
