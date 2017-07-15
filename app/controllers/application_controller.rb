class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def require_user
    return if current_user
    # Make sure we get redirected back to the page we were asking for.
    redirect_to "/auth/orcid?origin=#{env['REQUEST_URI']}"
  end

  def require_admin_user
    redirect_to '/sessions/new' unless current_user && current_user.admin?
  end

  def require_complete_profile
    return if current_user.profile_complete?
    redirect_to(:back, notice: 'Please add an email address to your account before submitting')
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
