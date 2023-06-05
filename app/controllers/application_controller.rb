class ApplicationController < ActionController::Base
  include Pagy::Backend
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def require_user
    unless current_user
      flash[:error] = "Please login first"
      redirect_back fallback_location: :root
      false # throw :abort
    end
  end

  def require_admin_user
    require_user
    if current_user && !current_user.admin?
      flash[:error] = "You are not permitted to view that page"
      redirect_to(:root)
      false # throw :abort
    end
  end

  def require_editor
    require_user
    if current_user && !current_user.editor?
      flash[:error] = "You are not permitted to view that page"
      redirect_to(:root)
      false # throw :abort
    end
  end

  def require_aeic
    require_user
    if current_user && !current_user.aeic?
      flash[:error] = "You are not permitted to view that page"
      redirect_to(:root)
      false # throw :abort
    end
  end

  def require_complete_profile
    if !current_user.profile_complete?
      redirect_back(notice: "Please add an email address to your account before submitting", fallback_location: root_path)
    end
  end

private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user


  def current_editor
    current_user && current_user.editor?
  end
  helper_method :current_editor

  def record_not_found
    render plain: "404 Not Found", status: 404
  end
end
