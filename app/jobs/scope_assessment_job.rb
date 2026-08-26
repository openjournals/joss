# Runs one scope assessment off the request cycle. With no queue backend
# configured, Rails' built-in :async adapter runs this in a thread inside the
# web process — fine for click-triggered one-offs at JOSS volume. A job lost
# to a dyno restart is not a problem: the scheduled sweep assesses any
# incoming paper that still lacks an assessment.
#
# The Runner already resolves every failure to a needs_manual/error
# assessment row, so no retries here — retrying would just duplicate rows.
class ScopeAssessmentJob < ApplicationJob
  queue_as :default
  discard_on StandardError

  def perform(paper)
    ScopeReview::Runner.assess(paper)
  end
end
