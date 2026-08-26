# Work queue for automated scope assessments. The per-paper detail and all
# decisions live on the paper admin page (papers/_scope_assessment partial);
# this controller provides the queue index and the decision endpoints.
# Recording a decision here performs no outward action — desk-reject + email
# is PapersController#desk_reject, an explicit human step.
class ScopeAssessmentsController < ApplicationController
  before_action :require_aeic
  before_action :find_assessment, only: %i[show update approve override rerun]

  def index
    @track = Track.find(params[:track_id]) if params[:track_id].present?

    @assessments = filtered(ScopeAssessment.includes(:paper))
                   .where(status: %w[pending needs_manual error])
                   .latest_first
                   .sort_by { |a| [a.queue_position, a.created_at] }
    @decided = filtered(ScopeAssessment.includes(:paper, :decided_by)).decided.latest_first.limit(25)
  end

  # Assessment detail lives on the paper show page (AEiC-only card).
  def show
    redirect_to paper_path(@assessment.paper)
  end

  # Queue a first assessment for a paper that doesn't have one (runs in the
  # background — a clone can take minutes, far past the request timeout).
  def create
    paper = Paper.find(params.require(:paper_id))
    ScopeAssessmentJob.perform_later(paper)
    redirect_to paper_path(paper), notice: "Assessment queued — it will appear here in a minute or two (refresh)."
  end

  def update
    @assessment.update!(assessment_params)
    redirect_to paper_path(@assessment.paper), notice: "Draft note updated."
  end

  # "The automation got it right" — records concurrence for calibration
  # metrics without touching the paper.
  def approve
    @assessment.approve!(current_user.editor)
    redirect_to paper_path(@assessment.paper), notice: "Assessment approved."
  end

  # "The automation got it wrong" — also calibration signal.
  def override
    @assessment.override!(current_user.editor)
    redirect_to paper_path(@assessment.paper), notice: "Assessment marked overridden."
  end

  def rerun
    ScopeAssessmentJob.perform_later(@assessment.paper)
    redirect_to paper_path(@assessment.paper), notice: "Re-assessment queued — refresh in a minute or two."
  end

  private

  def filtered(scope)
    @track ? scope.joins(:paper).where(papers: { track_id: @track.id }) : scope
  end

  def find_assessment
    @assessment = ScopeAssessment.find(params[:id])
  end

  def assessment_params
    params.require(:scope_assessment).permit(:draft_note)
  end
end
