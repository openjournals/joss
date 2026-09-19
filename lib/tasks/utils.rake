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
end
