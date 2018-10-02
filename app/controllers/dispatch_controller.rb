class DispatchController < ApplicationController
  include DispatchHelper
  include SettingsHelper

  protect_from_forgery :except => [ :api_start_review, :api_deposit ]
  respond_to :json

  def github_recevier
    payload = JSON.parse(request.body.read)

    if valid_webhook(payload)
      handle(payload)
      head 200
    else
      head :unprocessable_entity
    end
  end

  def valid_webhook(payload)
    # TODO: validate that this webhook is indeed coming from GitHub
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

  def api_start_review
    if params[:secret] == ENV['WHEDON_SECRET']
      @paper = Paper.find_by_meta_review_issue_id(params[:id])
      if @paper.start_review!(nil, params[:editor], params[:reviewers])
        render :json => @paper.to_json, :status => '201'
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

      @paper.update_attributes(
        :doi => params[:doi],
        :archive_doi => params[:archive_doi],
        :accepted_at => Time.now,
        :citation_string => params[:citation_string],
        :authors => params[:authors],
        :title => params[:title]
      )

      if @paper.accept!
        render :json => @paper.to_json, :status => '201'
      else
        head :unprocessable_entity
      end
    else
      head :forbidden
    end
  end
end
