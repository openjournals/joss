class TracksController < ApplicationController
  before_action :require_admin_user
  before_action :set_track, only: [:show, :edit, :update, :destroy, :remove]
  before_action :load_aeics, only: [:new, :edit]

  def index
    @tracks = Track.includes(:aeics).all
  end

  def show
  end

  def new
    @track = Track.new
  end

  def edit
  end

  def create
    @track = Track.new(track_params)

    if @track.save
      redirect_to @track, notice: 'Track was successfully created.'
    else
      load_aeics
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @track.update(track_params)
      redirect_to @track, notice: 'Track was successfully updated.'
    else
      load_aeics
      render :edit, status: :unprocessable_entity
    end
  end

  def remove
    @editors = @track.editors
    @subjects = @track.subjects
    @other_tracks = Track.where.not(id: @track.id)
    @assigned_papers = @track.papers.count
    @in_progress_papers = @track.papers.in_progress.count
  end

  def destroy
    @assigned_papers = @track.papers.count

    if params[:new_track_id].blank? && @assigned_papers > 0
      @editors = @track.editors
      @subjects = @track.subjects
      @other_tracks = Track.where.not(id: @track.id)
      @in_progress_papers = @track.papers.in_progress.count
      @track.errors.add :base, "You must provide a track to assign all papers from this track before deleting it."
      render :remove, status: :unprocessable_entity
    else
      if @assigned_papers > 0
        new_track = Track.find(params[:new_track_id])
        @track.papers.update_all(track_id: new_track.id)
      end
      @track.destroy
      redirect_to tracks_url, notice: 'Track was successfully destroyed.'
    end
  end

  private
    def set_track
      @track = Track.find(params[:id])
    end

    def load_aeics
      @aeics = Editor.board.order(first_name: :asc)
    end

    def track_params
      params.require(:track).permit(:name, :short_name, :code, :last_name, { aeic_ids: [] })
    end
end
