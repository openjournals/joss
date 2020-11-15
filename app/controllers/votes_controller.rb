class VotesController < ApplicationController
  before_action :find_paper
  before_action :require_editor

  def create
    if params[:commit].include?("in scope")
      logger.info "IN SCOPE"
      kind = "in-scope"
    elsif params[:commit].include?("out of scope")
      logger.info "OUT OF SCOPE"
      kind = "out-of-scope"
    elsif params[:commit].include?("Just comment")
      logger.info "JUST COMMENTING"
      kind = "comment"
    end

    params = vote_params.merge!(editor_id: current_user.editor.id, kind: kind)

    @vote = @paper.votes.build(params)

    if previous_vote = Vote.find_by_paper_id_and_editor_id(@paper, current_user.editor)
      previous_vote.destroy!
    end

    if @vote.save
      flash[:notice] = "Vote recorded"
      redirect_to paper_path(@paper)
    else
      flash[:error] = "Comment can't be empty"
      redirect_to paper_path(@paper)
    end
  end

  private

  def vote_params
    params.require(:vote).permit(:user_id, :comment)
  end

  def find_paper
    @paper = Paper.find_by_sha(params[:paper_id])
  end
end
