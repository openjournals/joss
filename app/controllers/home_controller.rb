class HomeController < ApplicationController
  def index
    @featured = Paper.featured
    @papers = Paper.visible.limit(10)
    @recent_papers = Paper.visible.recent.limit(10)
    @popular_papers = Paper.popular.visible.recent.limit(10)
  end

  def about

  end

  def editors
    render :text => 'Ya, we have editors'
  end

  def update_email
    raise "No user" unless current_user
    if current_user.update_attributes(user_params)
      redirect_to(:back, :notice => "Email saved.")
    end
  end


private

  def user_params
    params.require(:user).permit(:email)
  end
end
