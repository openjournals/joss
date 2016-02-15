class PapersController < ApplicationController
  before_filter :require_user, :only => %w(new edit create submit update)

  def recent
    @papers = Paper.recent.visible.paginate(
                :page => params[:page],
                :per_page => 10
              )

    @selected = "recent"

    respond_to do |format|
      format.atom { render :template => 'papers/index' }
      format.json { render :json => @papers }
      format.html { render :template => 'papers/index' }
    end
  end

  def index
    @papers = Paper.visible.paginate(
                :page => params[:page],
                :per_page => 10
              )

    @selected = "all"

    respond_to do |format|
      format.atom { render :template => 'papers/index' }
      format.json { render :json => @papers }
      format.html { render :template => 'papers/index' }
    end
  end

  def popular
    # TODO: Need to order by popularity here
    @papers = Paper.visible.paginate(
                :page => params[:page],
                :per_page => 10
              )

    @selected = "popular"

    respond_to do |format|
      format.atom { render :template => 'papers/index' }
      format.json { render :json => @papers }
      format.html { render :template => 'papers/index' }
    end
  end

  def submitted
    @papers = Paper.submitted.paginate(
                :page => params[:page],
                :per_page => 10
              )

    @selected = "submitted"

    respond_to do |format|
      format.atom { render :template => 'papers/index' }
      format.json { render :json => @papers }
      format.html { render :template => 'papers/index' }
    end
  end

  def new
    @paper = Paper.new
  end

  def show
    @paper = Paper.find_by_sha(params[:id])
  end

  def create
    @paper = Paper.new(paper_params)

    if @paper.save
      redirect_to paper_path(@paper)
    else
      render :action => :new
    end
  end

  private

  def paper_params
    params.require(:paper).permit(:title, :repository_url, :archive_doi, :body)
  end
end
