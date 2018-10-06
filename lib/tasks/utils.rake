require "util/console_extensions"
include ConsoleExtensions

namespace :utils do

  def utils_initialize_activities(paper)
    activities = {
      'issues' => {
        'commenters' => {
          'pre-review' => {},
          'review' => {}
        },
        'comments' => []
      }
    }

    paper.activities = activities
    paper.save
  end

  # Parse the incoming payload and do something with it...
  def utils_parse_payload!(paper, comment, pre_review)
    sender = comment.user.login
    comment_body = comment.body
    commented_at = comment.created_at
    comment_url = comment.html_url

    issues = paper.activities['issues']

    if pre_review
      kind = 'pre-review'
    else
      kind = 'review'
    end

    issues['comments'].unshift(
      'author' => sender,
      'comment' => comment_body,
      'commented_at' => commented_at,
      'comment_url' => comment_url,
      'kind' => kind
    )

    # Something has gone wrong if this isn't the case...
    if issues['commenters'][kind].has_key?(sender)
      issues['commenters'][kind][sender] += 1
    else
      issues['commenters'][kind].merge!(sender => 1)
    end

    # Only keep the last 5 comments
    issues['comments'] = issues['comments'].take(5)

    # Finally save the paper
    paper.save
  end

  desc "Populate editors and reviewers"
  task :populate_editors_and_reviewers => :environment do
    reviews_repo = Rails.application.settings["reviews"]
    Paper.everything.where('id < 255').each do |paper|
      puts "Paper: #{paper.id}"
      if paper.review_issue_id
        issue = GITHUB.issue(reviews_repo, paper.review_issue_id)

        editor_handle = issue.body.match(/\*\*Editor:\*\*\s*.@(\S*)/)[1]
        reviewers = issue.body.match(/Reviewers?:\*\*\s*(.+?)\r?\n/)[1].split(", ") - ["Pending"]

        if editor_handle == "biorelated"
          editor = Editor.find_by_login "george-githinji"
        else
          editor = Editor.find_by_login(editor_handle)
        end

        if paper.editor && (paper.editor.login != editor.login)
          puts "WARNING: Changing editor from #{paper.editor.login} to #{editor.login}"
        end

        if paper.reviewers != reviewers.each(&:strip!)
          puts "WARNING: Changing reviewers from #{paper.reviewers} to #{reviewers.each(&:strip!)}"
        end

        paper.set_editor(editor)
        paper.set_reviewers(reviewers.join(','))

        puts "Paper: #{paper.id}, Editor: #{editor.login}, Reviewers: #{reviewers}"
      else
        puts "No review_issue_id for #{paper.id}"
      end
    end
  end

  desc "Populate activities"
  task :populate_activities => :environment do
    reviews_repo = Rails.application.settings["reviews"]

    puts "Starting with in progress papers"
    Paper.in_progress.each do |paper|
      puts "Working with #{paper.meta_review_issue_id} "
      next unless paper.meta_review_issue_id

      pre_review_comments = GITHUB.issue_comments(reviews_repo, paper.meta_review_issue_id)
      utils_initialize_activities(paper)

      pre_review_comments.each do |comment|
        utils_parse_payload!(paper, comment, pre_review=true)
      end

      next if paper.review_issue_id.nil?

      review_comments = GITHUB.issue_comments(reviews_repo, paper.review_issue_id)
      review_comments.each do |comment|
        utils_parse_payload!(paper, comment, pre_review=false)
      end
    end

    puts "Next doing accepted papers"
    Paper.visible.each do |paper|
      puts "Working with #{paper.id}"

      utils_initialize_activities(paper)

      if paper.meta_review_issue_id
        # Initialize the activities hash

        pre_review_comments = GITHUB.issue_comments(reviews_repo, paper.meta_review_issue_id)

        pre_review_comments.each do |comment|
          utils_parse_payload!(paper, comment, pre_review=true)
        end
      end

      # Skip if there's no review issue
      next if paper.review_issue_id.nil?

      review_comments = GITHUB.issue_comments(reviews_repo, paper.review_issue_id)
      review_comments.each do |comment|
        utils_parse_payload!(paper, comment, pre_review=false)
      end
    end
  end

  desc "Clear activities"
  task :clear_activities => :environment do
    Paper.all.each do |paper|
      paper.activities = nil
      paper.save
    end
  end


  desc "Add user_ids to editors"
  task :add_user_ids => :environment do
    Editor.all.each do |e|
      u = User.find_by_github_username("@#{e.login}")
      if u.nil?
        puts e.login and return
      else
        e.user_id = u.id
        e.save
      end
    end
  end

  desc "Add editor_ids to papers"
  task :add_editor_ids => :environment do
    reviews_repo = Rails.application.settings["reviews"]
    open_review_issues = ReviewIssue.download_review_issues(reviews_repo)
    closed_review_issues = ReviewIssue.download_completed_reviews(reviews_repo)
    review_issues = open_review_issues + closed_review_issues

    review_issues.flatten.each do |review|
      puts review.number
      # The first two here are recent reviews (can remove this when running in
      # production). The second two are test submissions.

      next if [67, 626].include? review.number
      paper = dat(review.number)

      editor = review.editor.gsub('@', '')

      # This is a pre-preview issue without an editor asssigned
      if editor == "Pending" && review.pre_review?
        puts "Doing nothing for #{review.number}"
      else
        if editor == 'biorelated'
          editor = Editor.where('login = ? OR login = ?', editor, 'george-githinji').first
        else
          editor = Editor.where('login = ?', editor).first
        end

        paper.update_attribute(:editor_id, editor.id)
        paper.update_attribute(:reviewers, review.reviewers)
      end
    end
  end
end
