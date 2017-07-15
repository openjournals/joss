class HomeController < ApplicationController
  before_filter :require_user, only: %w[profile update_profile]

  def index
    @featured = Paper.featured
    @papers = Paper.everything.limit(10)
    @recent_papers = Paper.visible.recent.limit(10)
    @submitted_papers = Paper.in_progress.limit(10)
    @popular_papers = Paper.popular.visible.recent.limit(10)
  end

  def about; end

  def update_profile
    check_github_username

    return unless current_user.update_attributes(user_params)
    redirect_to(:back, notice: 'Profile updated')
  end

  def profile
    @user = current_user
  end

  private

  def check_github_username
    return unless user_params.key?('github_username')
    return if user_params['github_username'].strip.start_with?('@')
    old = user_params['github_username']
    user_params['github_username'] = old.prepend('@')
  end

  def user_params
    params.require(:user).permit(:email, :github_username)
  end
end
