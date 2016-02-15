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
end
