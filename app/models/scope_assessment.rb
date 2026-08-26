# One automated scope-screening run for a paper (spec: assisted scope review).
# Versioned: a paper gets a new row each time it is (re-)assessed — e.g. after
# the author pushes a new paper.md — so the audit trail is append-only.
#
# The recommendation is advisory. Only an EiC decision (approve/override from
# the dashboard) carries editorial weight, and no outward action is ever taken
# by the pipeline itself.
class ScopeAssessment < ApplicationRecord
  belongs_to :paper
  belongs_to :decided_by, class_name: "Editor", optional: true

  RECOMMENDATIONS = %w[
    PROCEED BORDERLINE_PROCEED REQUIRES_VERIFICATION AWAITING_PAPER_UPDATE
    BORDERLINE_REJECT DESK_REJECT NEEDS_MANUAL
  ].freeze
  STATUSES = %w[pending approved overridden needs_manual error].freeze
  TIERS = %w[L0 L1 L2 L3].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :recommendation, inclusion: { in: RECOMMENDATIONS }, allow_nil: true
  validates :tier_reached, inclusion: { in: TIERS }, allow_nil: true

  scope :pending, -> { where(status: "pending") }
  scope :needs_manual, -> { where(status: "needs_manual") }
  scope :actionable, -> { where(status: %w[pending needs_manual]) }
  scope :decided, -> { where(status: %w[approved overridden]) }
  scope :latest_first, -> { order(created_at: :desc) }

  # Ordered worst-first for the dashboard queue.
  RECOMMENDATION_ORDER = %w[
    DESK_REJECT BORDERLINE_REJECT NEEDS_MANUAL REQUIRES_VERIFICATION
    AWAITING_PAPER_UPDATE BORDERLINE_PROCEED PROCEED
  ].freeze

  def self.latest_for(paper)
    where(paper: paper).latest_first.first
  end

  def gate_results
    gates.is_a?(Hash) ? (gates["gates"] || {}) : {}
  end

  def gate_notes
    gates.is_a?(Hash) ? (gates["gate_notes"] || {}) : {}
  end

  def triggers
    gates.is_a?(Hash) ? Array(gates["triggers"]) : []
  end

  def decided?
    %w[approved overridden].include?(status)
  end

  # The assessment is stale when the analyzed head no longer matches the
  # repository — the sweep re-runs stale assessments for still-incoming papers.
  def stale_for?(current_head_sha)
    repo_head_sha.present? && current_head_sha.present? && repo_head_sha != current_head_sha
  end

  def approve!(editor)
    update!(status: "approved", decided_by: editor, decided_at: Time.current)
  end

  def override!(editor)
    update!(status: "overridden", decided_by: editor, decided_at: Time.current)
  end

  def queue_position
    RECOMMENDATION_ORDER.index(recommendation) || RECOMMENDATION_ORDER.length
  end
end
