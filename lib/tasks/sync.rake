namespace :sync do
  desc "Papers cleanup"
  task cleanup_paper_branches: :environment do
    reviews_repo = Rails.application.settings["reviews"]
    papers_repo = Rails.application.settings["papers_repo"]
    # Only check for issues in the last 3 days
    target_time = (Time.now - 3.days).strftime('%Y-%m-%dT%H:%M:%S%z')
    closed_issues = GITHUB.list_issues(reviews_repo, state: 'closed', since: target_time)
    branch_names = GITHUB.branches(papers_repo).collect {|b| b.name}

    closed_issues.each do |issue|
      id = "%05d" % issue.number
      wouldbe_branch_name = "#{Rails.application.settings["abbreviation"].downcase}.#{id}"

      if branch_names.include?(wouldbe_branch_name)
        puts "Deleting #{wouldbe_branch_name}"
        GITHUB.delete_branch(papers_repo, wouldbe_branch_name)
      end
    end
  end
end
