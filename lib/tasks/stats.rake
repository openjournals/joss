require 'base64'
require 'google_drive'

def stats_clean_up_github_handle(github_handle)
  if github_handle.include?('https://github.com')
    return github_handle.gsub('https://github.com/', '')
  elsif github_handle.include?('@')
    return github_handle.gsub('@', '')
  else
    return nil
  end
end

def stats_reviews_all_time_for(github_handle)
  return Paper.where(":reviewer = ANY(reviewers)", reviewer: "@#{github_handle}").count
end

def stats_reviews_last_year_for(github_handle)
  return Paper.since(1.year.ago).where(":reviewer = ANY(reviewers)", reviewer: "@#{github_handle}").count
end

def stats_reviews_last_quarter_for(github_handle)
  return Paper.since(3.months.ago).where(":reviewer = ANY(reviewers)", reviewer: "@#{github_handle}").count
end

def stats_active_reviews_for(github_handle)
  return Paper.in_progress.where(":reviewer = ANY(reviewers)", reviewer: "@#{github_handle}").count
end

namespace :stats do
  desc "Update the Google sheet with reviewer counts"
  task review_counts: :environment do
    decoded = Base64.decode64(ENV['GAUTH'].gsub("\\n", "\n"))
    client_secret = StringIO.new(decoded)
    google = GoogleDrive::Session.from_service_account_key(client_secret)

    sheet = google.spreadsheet_by_key("1PAPRJ63yq9aPC1COLjaQp8mHmEq3rZUzwUYxTulyu78").worksheets[0]

    sheet.rows.each_with_index do |row, index|
      # Need to slow down for the Google API.
      puts "Working with #{index}"
      next if index < 4
      github_handle = sheet["A#{index}"]

      if handle = stats_clean_up_github_handle(github_handle)
        sheet["A#{index}"] = handle
      else
        handle = github_handle
      end

      sheet["G#{index}"] = stats_active_reviews_for(handle)
      sheet["H#{index}"] = stats_reviews_all_time_for(handle)
      sheet["I#{index}"] = stats_reviews_last_year_for(handle)
      sheet["J#{index}"] = stats_reviews_last_quarter_for(handle)
    end
    sheet.save
  end

  desc "Find most published authors of all time"
  task most_published_authors: :environment do
    # Find all the users who have published papers
    users = User.joins(:papers).where(papers: { state: 'accepted' }).distinct

    # Sort them by the number of papers they've published
    users = users.sort_by { |u| u.papers.accepted.count }.reverse

    # Print out the authors with more than one published paper in JOSS, 
    # with a link to published papers on JOSS (format https://joss.theoj.org/papers/by/username)
    # the number of papers they've published, name, and email address, and whether they're an editor
    users.select { |u| u.papers.accepted.count > 1 }.each do |u|
      puts "#{u.papers.accepted.count},#{u.name},#{u.email},#{u.editor? ? 'editor' : 'non-editor'},(https://joss.theoj.org/papers/by/#{u.github_username})"
    end;nil
  end
end
