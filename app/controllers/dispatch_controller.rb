require 'base64'
require 'issue'

class DispatchController < ApplicationController
  include DispatchHelper
  include SettingsHelper

  protect_from_forgery except: [  :api_assign_editor, :api_assign_reviewers,
                                  :api_deposit, :api_update_paper_info, :api_reject,
                                  :api_start_review, :api_withdraw, :api_editor_invite ]
  respond_to :json

  def github_receiver
    webhook = Issue::Webhook.new(secret_token: ENV["GH_SECRET"],
                                 origin: Rails.application.settings["reviews"],
                                 accept_events: ["issues", "issue_comment"])
    payload, error = webhook.parse_request(request)

    if webhook.errored?
      head error.status, msg: error.message
    else
      parse_payload!(payload)
      head 200
    end
  end

  def api_assign_editor
    if params[:secret] == ENV['BOT_SECRET']
      paper = Paper.find_by_meta_review_issue_id(params[:id])
      paper = Paper.find_by_review_issue_id(params[:id]) if paper.nil?
      editor_params = params[:editor].gsub(/^\@/, "")
      editor = Editor.find_by_login(editor_params)
      return head :unprocessable_entity unless paper && editor
      paper.set_editor(editor)
    else
      head :forbidden
    end
  end

  def api_editor_invite
    if params[:secret] == ENV['BOT_SECRET']
      paper = Paper.find_by_meta_review_issue_id(params[:id])
      return head :unprocessable_entity unless paper
      if paper.invite_editor(params[:editor])
        head :no_content
      else
        head :unprocessable_entity
      end
    else
      head :forbidden
    end
  end

  def api_assign_reviewers
    if params[:secret] == ENV['BOT_SECRET']
      paper = Paper.find_by_meta_review_issue_id(params[:id])
      return head :unprocessable_entity unless paper
      paper.set_reviewers(params[:reviewers])
    else
      head :forbidden
    end
  end

  def api_update_paper_info
    if params[:secret] == ENV['BOT_SECRET']
      paper = Paper.find_by_meta_review_issue_id(params[:id])
      paper = Paper.find_by_review_issue_id(params[:id]) if paper.nil?
      return head :unprocessable_entity unless paper

      paper.repository_url = params[:repository_url] if params[:repository_url].present?

      paper.save
    else
      head :forbidden
    end
  end

  def api_reject
    if params[:secret] == ENV['BOT_SECRET']
      paper = Paper.where('review_issue_id = ? OR meta_review_issue_id = ?', params[:id], params[:id]).first
      return head :unprocessable_entity unless paper
      if paper.reject!
        head :no_content
      else
        head :unprocessable_entity
      end
    else
      head :forbidden
    end
  end

  def api_withdraw
    if params[:secret] == ENV['BOT_SECRET']
      paper = Paper.where('review_issue_id = ? OR meta_review_issue_id = ?', params[:id], params[:id]).first
      return head :unprocessable_entity unless paper
      if paper.withdraw!
        head :no_content
      else
        head :unprocessable_entity
      end
    else
      head :forbidden
    end
  end

  def api_start_review
    if params[:secret] == ENV['BOT_SECRET']
      @paper = Paper.find_by_meta_review_issue_id(params[:id])
      if @paper.start_review!(params[:editor], params[:reviewers], params[:branch])
        render json: @paper.to_json, status: '201'
      else
        head :unprocessable_entity
      end
    else
      head :forbidden
    end
  end

  def api_deposit
    if params[:secret] == ENV['BOT_SECRET']
      @paper = Paper.find_by_review_issue_id(params[:id])

      if params[:metadata]
        metadata = JSON.parse(Base64.decode64(params[:metadata]))
      else
        metadata = nil
      end

      @paper.update(
        doi: params[:doi],
        archive_doi: params[:archive_doi],
        accepted_at: @paper.accepted_at.present? ? @paper.accepted_at : Time.now,
        citation_string: params[:citation_string],
        authors: params[:authors],
        title: params[:title],
        metadata: metadata
      )

      if @paper.accept!
        render json: @paper.to_json, status: '201'
      else
        head :unprocessable_entity
      end
    else
      head :forbidden
    end
  end

  def api_retract
    if params[:secret] == ENV['BOT_SECRET']
      paper = Paper.find_by_doi!(params[:doi])
      return head :unprocessable_entity if paper.retracted?

      if params[:metadata]
        metadata = JSON.parse(Base64.decode64(params[:metadata]))
      else
        metadata = {}
      end

      retraction_paper = Paper.new
      retraction_paper.doi = metadata[:doi] || "#{paper.doi}R"
      retraction_paper.retraction_for_id = paper.id
      retraction_paper.title = metadata[:title] || "Retraction notice for: #{paper.title}"
      retraction_paper.body = "Retraction notice for: #{paper.title}"
      retraction_paper.authors = "Editorial Board"
      retraction_paper.repository_url = paper.repository_url
      retraction_paper.software_version = paper.software_version
      retraction_paper.track_id = paper.track_id
      retraction_paper.citation_string = params[:citation_string]
      retraction_paper.submission_kind = "new"
      retraction_paper.state = "accepted"
      retraction_paper.metadata = metadata
      retraction_paper.accepted_at = Time.now
      retraction_paper.review_issue_id = paper.review_issue_id

      if paper.track.nil?
        submitting_author = Editor.includes(:user).board.select {|e| e.user.present? }.first.user
      else
        submitting_author = paper.track.aeics.select {|e| e.user.present? }.first.user
      end
      submitting_author = User.where(admin: true).first if submitting_author.nil?

      retraction_paper.submitting_author = submitting_author

      if retraction_paper.save! && retraction_paper.accept!
        paper.update(retraction_notice: params[:retraction_notice]) if params[:retraction_notice].present?
        paper.retract!
        render json: retraction_paper.to_json, status: '201'
      else
        head :unprocessable_entity
      end
    else
      head :forbidden
    end
  end

end
