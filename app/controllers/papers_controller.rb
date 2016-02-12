class PapersController < ApplicationController
  before_filter :require_user, :only => %w(new edit create submit update)

  def index
    @papers = Paper.recent.visible.paginate(
                :page => params[:page],
                :per_page => 10
              )

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
      # TODO: do something with the (un)happy path
    end
  end

  private

  def paper_params
    params.require(:paper).permit(:title, :repository_url, :archive_doi, :body)
  end
end
