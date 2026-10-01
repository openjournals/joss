require "csv"

class AeicDashboardController < ApplicationController
  before_action :require_aeic

  EDITOR_EMAIL_GROUPS = {
    "board" => { scope: :board, filename: "aeic-editor-emails" },
    "topic" => { scope: :topic, filename: "topic-editor-emails" }
  }.freeze

  def index
    if params[:track_id].present?
      @track = Track.find(params[:track_id])
      recommend_accept_labels = ["recommend-accept", @track.label].compact.join(",")
      query_scope_labels = ["query-scope", @track.label].compact.join(",")
    else
      params[:track_id] = nil
      recommend_accept_labels = "recommend-accept"
      query_scope_labels = "query-scope"
    end

    @recommend_accept = GITHUB.issues(Rails.application.settings["reviews"], labels: recommend_accept_labels, state:"open")
    @with_query_scope = GITHUB.issues(Rails.application.settings["reviews"], labels: query_scope_labels, state:"open")
  end

  def editor_emails
    respond_to do |format|
      format.html do
        @board_count = Editor.board.count
        @topic_count = Editor.topic.count
      end

      format.csv do
        group = EDITOR_EMAIL_GROUPS[params[:group]]
        return head(:not_found) unless group

        editors = Editor.public_send(group[:scope]).order(:last_name, :first_name)
        csv = CSV.generate do |rows|
          rows << ["first_name", "last_name", "login", "email"]
          editors.each { |e| rows << [e.first_name, e.last_name, e.login, e.email] }
        end

        send_data csv, type: "text/csv", filename: "#{group[:filename]}-#{Date.today}.csv"
      end
    end
  end
end
