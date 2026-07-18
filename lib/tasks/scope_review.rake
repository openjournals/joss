require "open3"

# Scope-review sweep — designed to run from Heroku Scheduler (a one-off dyno
# every N minutes), so there is no resident worker. All output goes to stdout
# for the scheduler log.
#
#   rake scope_review:sweep               # assess unassessed incoming papers (bounded by LIMIT, default 10)
#   rake scope_review:sweep STALE=1       # also re-assess papers whose repo HEAD moved since last run
#   rake scope_review:assess PAPER=123    # force a (re-)assessment of one paper, by id or sha
namespace :scope_review do
  desc "Assess incoming papers that need a scope screening"
  task sweep: :environment do
    unless ScopeReview.enabled?
      puts "scope_review.enabled is false in settings — nothing to do."
      next
    end

    limit = ENV.fetch("LIMIT", 10).to_i
    candidates = Paper.where(state: %w[submitted review_pending], editor_id: nil)
                      .order(:created_at)

    todo = candidates.select { |paper| needs_assessment?(paper, recheck_stale: ENV["STALE"].present?) }
    puts "#{candidates.count} incoming papers, #{todo.size} need assessment (processing up to #{limit})."

    todo.first(limit).each do |paper|
      print "Assessing paper ##{paper.id} (#{paper.repository_url})… "
      started = Time.current
      assessment = ScopeReview::Runner.assess(paper)
      puts "#{assessment.recommendation || assessment.status} " \
           "[#{assessment.tier_reached}] (#{(Time.current - started).round(1)}s)"
    rescue StandardError => e
      puts "FAILED: #{e.class}: #{e.message}"
    end
  end

  desc "Assess a single paper by id or sha (PAPER=123 or PAPER=abc123...; PAPER_ID/PAPER_SHA also accepted)"
  task assess: :environment do
    identifier = ENV["PAPER"] || ENV["PAPER_ID"] || ENV["PAPER_SHA"] ||
                 abort("Usage: rake scope_review:assess PAPER=<id or sha>")
    paper = if identifier.match?(/\A\d+\z/)
              Paper.find(identifier)
            else
              Paper.find_by!(sha: identifier)
            end

    puts "Assessing paper ##{paper.id} (sha #{paper.sha}) — #{paper.repository_url}"
    assessment = ScopeReview::Runner.assess(paper)
    puts "#{assessment.recommendation || assessment.status} [#{assessment.tier_reached}] — status: #{assessment.status}"
    puts assessment.summary if assessment.summary.present?
    if assessment.draft_note.present?
      puts "--- draft note ---"
      puts assessment.draft_note
    end
  end

  def needs_assessment?(paper, recheck_stale: false)
    latest = paper.latest_scope_assessment
    return true if latest.nil?
    # One retry for errored runs, but never a tight loop on a persistent failure.
    return true if latest.status == "error" && latest.created_at < 24.hours.ago && paper.scope_assessments.where(status: "error").count < 3
    return false unless recheck_stale && !latest.decided?

    head = remote_head(paper.repository_url)
    head.present? && latest.stale_for?(head)
  end

  def remote_head(repo_url)
    stdout, _stderr, status = Open3.capture3(
      { "GIT_TERMINAL_PROMPT" => "0" }, "git", "ls-remote", "--", repo_url, "HEAD"
    )
    status.success? ? stdout.split("\t").first : nil
  end
end
