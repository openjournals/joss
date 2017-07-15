class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env['omniauth.auth'])

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
    redirect_to root_url, notice: 'Signed out!'
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
