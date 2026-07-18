class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(request.env["omniauth.auth"])

    # Get the user's name from ORCID API
    # OrcidWorker.perform_async(user.uid)

    session[:user_id] = user.id
    if request.env['omniauth.origin']
      redirect_to request.env['omniauth.origin']
    else
      redirect_to root_url
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end

  # Development-only: sign in as an existing user without ORCID OAuth
  # (e.g. against a local copy of the production DB). The route is only
  # drawn in development; this guard is belt-and-braces.
  def dev_login
    raise ActionController::RoutingError, "Not Found" unless Rails.env.development?

    user = User.find(params[:user_id])
    session[:user_id] = user.id
    redirect_to root_url, notice: "Signed in as #{user.name} (dev login)"
  end

private

  def auth_hash
    request.env['omniauth.auth']
  end
end
