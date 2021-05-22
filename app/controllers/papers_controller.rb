require 'open-uri'

class PapersController < ApplicationController
  include SettingsHelper

  before_action :require_user, only: %w(new create update withdraw)
  before_action :require_complete_profile, only: %w(create)
  before_action :require_admin_user, only: %w(start_meta_review archive reject)

  def recent
    @papers = Paper.visible.paginate(
                page: params[:page],
                per_page: 10
              )

    @selected = "recent"

    respond_to do |format|
      format.atom { render template: 'papers/index' }
      format.json { render json: @papers }
      format.html { render template: 'papers/index' }
    end
  end

  def index
    @papers = Paper.public_everything.paginate(
                page: params[:page],
                per_page: 10
              )

    @selected = "all"

    respond_to do |format|
      format.atom { render template: 'papers/index' }
      format.json { render json: @papers }
      format.html { render template: 'papers/index' }
    end
  end

  def popular
    if params[:since]
      @papers = Paper.unscoped.visible.since(params[:since]).order(accepted_at: :desc).paginate(
                  page: params[:page],
                  per_page: 10
                )
    else
      @papers = Paper.unscoped.visible.order(accepted_at: :desc).paginate(
                  page: params[:page],
                  per_page: 10
                )
    end


    @selected = "popular"

    respond_to do |format|
      format.atom { render template: 'papers/index' }
      format.json { render json: @papers }
      format.html { render template: 'papers/index' }
    end
  end

  def active
    @papers = Paper.public_in_progress.paginate(
                page: params[:page],
                per_page: 10
              )

    @selected = "active"

    respond_to do |format|
      format.atom { render template: 'papers/index' }
      format.json { render json: @papers }
      format.html { render template: 'papers/index' }
    end
  end

  def search
    @papers = Paper.none.page(1)
    @term = "results for empty search"

    if params['q']
      @papers = Paper.search(params['q'], fields: [:authors, :title, :tags, :languages],
                  page: params[:page],
                  per_page: 10)

      @term = "search results for '#{params['q']}'"
    end

    @filtering = true

    respond_to do |format|
      format.atom { render template: 'papers/index' }
      format.json { render json: @papers }
      format.html { render template: 'papers/index' }
    end
  end

  def filter
    @papers = Paper.none.page(1)
    @term = "Empty search term"
    if params['language']
      @papers = Paper.search(params['language'], fields: [languages: :exact], order: { accepted_at: :desc },
                  page: params[:page],
                  per_page: 10
                )
      @term = "in #{params['language']}"

    elsif params['author']
      @papers = Paper.search(params['author'], fields: [:authors], misspellings: false, order: { accepted_at: :desc },
                  page: params[:page],
                  per_page: 10
                )
      @term = "by #{params['author']}"

    elsif params['editor']
      @papers = Paper.search(params['editor'], fields: [:editor], misspellings: false, order: { accepted_at: :desc },
                  page: params[:page],
                  per_page: 10
                )
      @term = "edited by #{params['editor']}"

    elsif params['reviewer']
      @papers = Paper.search(params['reviewer'], fields: [:reviewers], misspellings: false, order: { accepted_at: :desc },
                  page: params[:page],
                  per_page: 10
                )
      @term = "reviewed by #{params['reviewer']}"

    elsif params['tag']
      @papers = Paper.search(params['tag'], fields: [:tags, :title], order: { accepted_at: :desc },
                  page: params[:page],
                  per_page: 10
                )
      @term = "#{params['tag']}"

    elsif params['issue']
      @papers = Paper.search(params['issue'], fields: [{issue: :exact}], order: { page: :desc },
                  page: params[:page],
                  per_page: 10
                )
      @term = "in issue #{params['issue']}"

    elsif params['volume']
      @papers = Paper.search(params['volume'], fields: [{volume: :exact}], order: { page: :desc },
                  page: params[:page],
                  per_page: 10
                )
      @term = "in volume #{params['volume']}"

    elsif params['year']
      @papers = Paper.search(params['year'], fields: [{year: :exact}], order: { page: :desc },
                  page: params[:page],
                  per_page: 10
                )
      @term = "in #{params['year']}"
    end

    @filtering = true

    respond_to do |format|
      format.atom { render template: 'papers/index' }
      format.json { render json: @papers }
      format.html { render template: 'papers/index' }
    end
  end

  def start_review
    @paper = Paper.find_by_sha(params[:id])

    if @paper.start_review!(params[:reviewer], params[:editor])
      flash[:notice] = "Review started"
      redirect_to paper_path(@paper)
    else
      flash[:error] = "Review could not be started"
      redirect_to paper_path(@paper)
    end
  end

  def start_meta_review
    @paper = Paper.find_by_sha(params[:id])

    if @paper.start_meta_review!(params[:editor], current_user.editor)
      flash[:notice] = "Review started"
      redirect_to paper_path(@paper)
    else
      flash[:error] = "Review could not be started"
      redirect_to paper_path(@paper)
    end
  end

  def reject
    @paper = Paper.find_by_sha(params[:id])

    if @paper.reject!
      flash[:notice] = "Paper rejected"
      redirect_to paper_path(@paper)
    else
      flash[:error] = "Paper could not be rejected"
      redirect_to paper_path(@paper)
    end
  end

  def withdraw
    @paper = Paper.find_by_sha(params[:id])

    unless current_user.is_owner_of?(@paper) || current_user.admin?
      redirect_to paper_path(@paper) and return
    end

    if @paper.withdraw!
      flash[:notice] = "Paper withdrawn"
      redirect_to paper_path(@paper)
    else
      flash[:error] = "Paper could not be withdrawn"
      redirect_to paper_path(@paper)
    end
  end

  def new
    @paper = Paper.new
  end

  def show
    if params[:doi] && valid_doi?
      @paper = Paper.find_by_doi!(params[:doi])
    else
      @paper = Paper.includes(notes: :editor).find_by_sha!(params[:id])
      # By default we want people to use the URLs with the DOI in the path if
      # the paper is accepted.
      if @paper.accepted?
        redirect_to @paper.seo_url, status: 301 and return
      end
    end

    # Don't show the paper to anyone other than the submitting author or an
    # admin.
    if @paper.invisible?
      head 404 and return unless can_see_hidden_paper?(@paper)
    end

    # The behaviour here for PDFs is to make it possible for the PDF to appear
    # to be on the current domain even when it might not be. This is essential
    # for Google Scholar and helpful for browser security warnings.
    respond_to do |format|
      format.html { render layout: false }
      format.pdf {
        data = URI.open(@paper.pdf_url)
        send_data data.read,
          :type => data.content_type,
          :disposition => 'inline'
      }
      format.json
    end
  end

  def lookup
    paper = Paper.where('review_issue_id = ? OR meta_review_issue_id = ?', params[:id], params[:id]).first!
    accepted_at = paper.accepted_at ? paper.accepted_at.strftime('%d %B %Y') : nil
    response = {  submitted: paper.created_at.strftime('%d %B %Y'),
                  accepted: accepted_at }
    render json: response.to_json
  end

  def valid_doi?
    if params[:doi] && params[:doi].include?("10.21105")
      return true
    else
      return false
    end
  end

  def create
    @paper = Paper.new(paper_params)

    @paper.submitting_author = current_user

    if @paper.save
      redirect_to paper_path(@paper)
    else
      render action: :new
    end
  end

  def status
    if params[:doi] && valid_doi?
      @paper = Paper.find_by_doi(params[:doi])
    else
      @paper = Paper.find_by_sha(params[:id])
    end

    # TODO: Remove these SVGs from the controller
    if @paper
      svg = @paper.status_badge
    else
      prefix = setting(:abbreviation)

      svg = "<svg xmlns='http://www.w3.org/2000/svg' width='102' height='20'><linearGradient id='b' x2='0' y2='100%'><stop offset='0' stop-color='#bbb' stop-opacity='.1'/><stop offset='1' stop-opacity='.1'/></linearGradient><mask id='a'><rect width='102' height='20' rx='3' fill='#fff'/></mask><g mask='url(#a)'><path fill='#555' d='M0 0h40v20H0z'/><path fill='#9f9f9f' d='M40 0h62v20H40z'/><path fill='url(#b)' d='M0 0h102v20H0z'/></g><g fill='#fff' text-anchor='middle' font-family='DejaVu Sans,Verdana,Geneva,sans-serif' font-size='11'><text x='20' y='15' fill='#010101' fill-opacity='.3'>#{prefix}</text><text x='20' y='14'>#{prefix}</text><text x='70' y='15' fill='#010101' fill-opacity='.3'>Unknown</text><text x='70' y='14'>Unknown</text></g></svg>"
    end

    if stale?(@paper)
      render inline: svg
    end
  end

  private

  def paper_params
    params.require(:paper).permit(:title, :repository_url, :archive_doi, :software_version, :suggested_editor, :body, :kind, :submission_kind)
  end

  def can_see_hidden_paper?(paper)
    return false unless current_user

    if current_user.admin? || current_user.is_owner_of?(paper)
      return true
    else
      return false
    end
  end
end
