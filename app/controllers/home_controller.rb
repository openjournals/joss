class HomeController < ApplicationController
  def index

  end

  def about

  end

  def editors
    render :text => 'Ya, we have editors'
  end
end
