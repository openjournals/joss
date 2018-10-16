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
  return Paper.visible.where(":reviewer = ANY(reviewers)", reviewer: "@#{github_handle}").count
end

def stats_reviews_last_year_for(github_handle)
  return Paper.since(1.year.ago).visible.where(":reviewer = ANY(reviewers)", reviewer: "@#{github_handle}").count
end

def stats_reviews_last_quarter_for(github_handle)
  return Paper.since(3.months.ago).visible.where(":reviewer = ANY(reviewers)", reviewer: "@#{github_handle}").count
end

def stats_active_reviews_for(github_handle)
  return Paper.in_progress.where(":reviewer = ANY(reviewers)", reviewer: "@#{github_handle}").count
end

namespace :stats do
  desc "Update the Google sheet with reviewer counts"
  task :review_counts => :environment do
    decoded = Base64.decode64(ENV['GAUTH'])
    client_secret = StringIO.new(decoded.gsub("\\n", "\n"))
    google = GoogleDrive::Session.from_service_account_key(client_secret)

    sheet = google.spreadsheet_by_key("1yDE8qShe8wRZQkYJd1WmZnwyLgG_UjJ91iPR0lrnMAc").worksheets[0]

    sheet.rows.each_with_index do |row, index|
      puts "Working with #{index}"
      next if index < 2
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
      sheet.save
    end
  end
end
