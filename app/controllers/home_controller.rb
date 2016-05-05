class HomeController < ApplicationController
  before_filter :require_user, :only => %w(profile update_profile)

  def index
    @featured = Paper.featured
    @papers = Paper.everything.limit(10)
    @recent_papers = Paper.visible.recent.limit(10)
    @submitted_papers = Paper.in_progress.limit(10)
    @popular_papers = Paper.popular.visible.recent.limit(10)
  end

  def about

  end

  def update_profile
    if current_user.update_attributes(user_params)
      redirect_to(:back, :notice => "Profile updated")
    end
  end

  def profile
    @user = current_user
  end

private

  def user_params
    params.require(:user).permit(:email, :github_username)
  end
end
