class AeicDashboardController < ApplicationController
  before_action :require_admin_user

  def index
    @recommend_accept = GITHUB.issues(Rails.application.settings["reviews"], labels: "recommend-accept", state:"open")
    @with_query_scope = GITHUB.issues(Rails.application.settings["reviews"], labels: "query-scope", state:"open")
  end

end
