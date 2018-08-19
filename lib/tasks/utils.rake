require "util/console_extensions"
include ConsoleExtensions
require 'pry'

namespace :utils do

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
