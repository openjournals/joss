class VotesController < ApplicationController
  before_action :find_paper
  before_action :require_editor

  def create
    if params[:commit].include?("in scope")
      puts "IN SCOPE"
      kind = "in-scope"
    elsif params[:commit].include?("out of scope")
      puts "OUT OF SCOPE"
      kind = "out-of-scope"
    end

    params = vote_params.merge!(editor_id: current_user.editor.id, kind: kind)

    @vote = @paper.votes.build(params)

    begin
      @vote.save!
      flash[:notice] = "Vote recorded"
      redirect_to paper_path(@paper)
    # Can't vote on the same item twice
    rescue ActiveRecord::RecordNotUnique => e
      flash[:error] = "Can't vote on the same item twice"
      render 'papers/show', layout: false
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
