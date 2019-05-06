namespace :sync do
  desc "Restrict permissions on reviews repository to those that need it"
  task :assignees => :environment do
    # We run this task daily on Heroku
    reviews_repo = Rails.application.settings["reviews"]
    open_issues = GITHUB.list_issues(reviews_repo, :state => 'open')

    open_issues.each do |issue|
      editor = issue.body.match(/\*\*Editor:\*\*\s*(@\S*|Pending)/i)[1]
      reviewers = issue.body.match(/Reviewers?:\*\*\s*(.+?)\r?\n/)[1].split(", ") - ["Pending"]
      assignees = reviewers << editor unless editor == "Pending"

      if assignees
        assignees = assignees.collect {|a| a.sub!(/^@/, '')}
        GITHUB.add_assignees(reviews_repo, issue.number, assignees)
      end
    end
  end
end
