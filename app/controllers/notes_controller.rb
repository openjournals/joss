class NotesController < ApplicationController
  before_action :find_paper
  before_action :require_editor

  def create
    params = note_params.merge!(editor_id: current_user.editor.id)

    @note = @paper.notes.build(params)

    if @note.save
      flash[:notice] = "Note saved"
      redirect_to paper_path(@paper)
    else
      flash[:error] = "Note can't be empty"
      redirect_to paper_path(@paper)
    end
  end

  def destroy
    @note = @paper.notes.find(params[:id])
    if @note.editor_id == current_user.editor.id
      @note.destroy!
      flash[:notice] = "Note deleted"
    end
    redirect_to paper_path(@paper)
  end

  private

  def note_params
    params.require(:note).permit(:comment)
  end

  def find_paper
    @paper = Paper.find_by_sha(params[:paper_id])
  end
end
