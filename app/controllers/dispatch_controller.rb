require 'base64'
require 'issue'

class DispatchController < ApplicationController
  include DispatchHelper
  include SettingsHelper

  protect_from_forgery except: [  :api_assign_editor, :api_assign_reviewers,
                                  :api_deposit, :api_editor_invite, :api_reject,
                                  :api_start_review, :api_withdraw ]
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
    if params[:secret] == ENV['WHEDON_SECRET']
      paper = Paper.find_by_meta_review_issue_id(params[:id])
      editor = Editor.find_by_login(params[:editor])
      return head :unprocessable_entity unless paper && editor
      paper.set_editor(editor)
    else
      head :forbidden
    end
  end

  def api_editor_invite
    if params[:secret] == ENV['WHEDON_SECRET']
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
    if params[:secret] == ENV['WHEDON_SECRET']
      paper = Paper.find_by_meta_review_issue_id(params[:id])
      return head :unprocessable_entity unless paper
      paper.set_reviewers(params[:reviewers])
    else
      head :forbidden
    end
  end

  def api_reject
    if params[:secret] == ENV['WHEDON_SECRET']
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
    if params[:secret] == ENV['WHEDON_SECRET']
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
    if params[:secret] == ENV['WHEDON_SECRET']
      @paper = Paper.find_by_meta_review_issue_id(params[:id])
      if @paper.start_review!(params[:editor], params[:reviewers])
        render json: @paper.to_json, status: '201'
      else
        head :unprocessable_entity
      end
    else
      head :forbidden
    end
  end

  def api_deposit
    if params[:secret] == ENV['WHEDON_SECRET']
      @paper = Paper.find_by_review_issue_id(params[:id])

      if params[:metadata]
        metadata = JSON.parse(Base64.decode64(params[:metadata]))
      else
        metadata = nil
      end

      @paper.update(
        doi: params[:doi],
        archive_doi: params[:archive_doi],
        accepted_at: Time.now,
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
end
