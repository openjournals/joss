require 'base64'

class DispatchController < ApplicationController
  include DispatchHelper
  include SettingsHelper

  protect_from_forgery except: [ :api_start_review, :api_deposit, :api_assign_editor, :api_assign_reviewers, :api_reject, :api_withdraw ]
  respond_to :json

  def github_recevier
    payload_body = request.body.read

    unless verify_signature(payload_body)
      head :unprocessable_entity and return
    end

    payload = JSON.parse(payload_body)

    if valid_webhook(payload)
      handle(payload)
      head 200
    else
      head :unprocessable_entity
    end
  end

  def verify_signature(payload_body)
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['GH_SECRET'], payload_body)
    return Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
  end

  def valid_webhook(payload)
    if payload['issue'].nil?
      return false
    else
      return false unless origin_correct?(payload)
      return true
    end
  end

  def origin_correct?(payload)
    payload['repository']['full_name'] == Rails.application.settings["reviews"]
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
