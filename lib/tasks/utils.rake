namespace :utils do
  desc "Sync reviewers column from paper metadata for all published papers. Set DRY_RUN=false to apply changes."
  task sync_reviewers_from_metadata: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    puts dry_run ? "DRY RUN — no changes will be saved. Set DRY_RUN=false to apply." : "Applying changes..."
    count = 0

    Paper.visible.find_each do |paper|
      next unless paper.metadata.present?

      metadata_reviewers = paper.metadata.dig('paper', 'reviewers') || []
      next if metadata_reviewers.empty?
      next if paper.reviewers.sort == metadata_reviewers.sort

      puts "Paper ##{paper.id} (#{paper.doi})"
      puts "  DB:       #{paper.reviewers.inspect}"
      puts "  metadata: #{metadata_reviewers.inspect}"

      paper.update_attribute(:reviewers, metadata_reviewers) unless dry_run
      count += 1
    end

    puts "#{dry_run ? 'Would update' : 'Updated'} #{count} papers."
  end

  desc "Sync reviewers column for in-progress papers from the GitHub issue header. Set DRY_RUN=false to apply changes."
  task sync_reviewers_from_github: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    puts dry_run ? "DRY RUN — no changes will be saved. Set DRY_RUN=false to apply." : "Applying changes..."
    reviews_repo = Rails.application.settings["reviews"]
    updated = 0
    skipped = 0

    Paper.unscoped.where(state: %w[review_pending under_review]).find_each do |paper|
      issue_id = paper.reviewers_source_issue_id
      next if issue_id.nil?

      begin
        body = GITHUB.issue(reviews_repo, issue_id).body
      rescue Octokit::Error => e
        puts "Paper ##{paper.id}: could not fetch issue ##{issue_id} (#{e.class})"
        skipped += 1
        next
      end

      parsed = IssueHeader.reviewers(body)
      if parsed.nil?
        puts "Paper ##{paper.id}: no reviewers-list marker in issue ##{issue_id}, skipping"
        skipped += 1
        next
      end

      next if paper.reviewers.map(&:downcase).sort == parsed.map(&:downcase).sort

      puts "Paper ##{paper.id} (issue ##{issue_id})"
      puts "  DB:     #{paper.reviewers.inspect}"
      puts "  GitHub: #{parsed.inspect}"

      unless dry_run
        paper.sync_reviewers_from_issue_body(body)

        # Comments logged as "none" from people who are now reviewers were
        # most likely made after they were assigned; relabel them.
        handles = parsed.map { |h| IssueComment.normalize(h) }
        relabeled = paper.issue_comments.where(role: "none")
                         .where("lower(login) IN (?)", handles)
                         .update_all(role: "reviewer")
        puts "  Relabeled #{relabeled} comment(s) as reviewer" if relabeled > 0
      end

      updated += 1
    end

    puts "#{dry_run ? 'Would update' : 'Updated'} #{updated} papers. Skipped #{skipped}."
  end
end
