require 'net/sftp'

namespace :portico do
  desc "Deposit"
  task deposit: :environment do
    Paper.visible.not_archived.each do |paper|
      Net::SFTP.start(ENV['PORTICO_HOST'], ENV['PORTICO_USERNAME'], password: ENV['PORTICO_PASSWORD']) do |sftp|
        if sftp.dir.glob("/", "10.21105.#{paper.journal_id}.zip").any?
          puts "Deposit already exists for 10.21105.#{paper.journal_id}"
        else
          crossref_file = "https://github.com/#{Rails.application.settings["papers_repo"]}/raw/master/#{paper.journal_id}/10.21105.#{paper.journal_id}.crossref.xml"
          pdf_file = "https://github.com/#{Rails.application.settings["papers_repo"]}/raw/master/#{paper.journal_id}/10.21105.#{paper.journal_id}.pdf"

          files_to_download = [crossref_file, pdf_file]

          # Create folder
          `mkdir tmp/10.21105.#{paper.journal_id}`

          # Download the files into this folder
          files_to_download.each do |file|
            `cd tmp/10.21105.#{paper.journal_id} && { curl -L -O #{file} ; cd -; }`
          end

          # Archive the review too...
          archive_review_object = Hash.new
          archive_review_object['review_issue'] = GITHUB.issue(Rails.application.settings["reviews"], paper.review_issue_id).to_h
          archive_review_object['review_issue_comments'] = GITHUB.issue_comments(Rails.application.settings["reviews"], paper.review_issue_id).map(&:to_h)

          File.open("tmp/10.21105.#{paper.journal_id}/review.json", "w") { |f|
            f.write(JSON.pretty_generate(archive_review_object))
          }

          # Zip the folder
          `zip tmp/10.21105.#{paper.journal_id}.zip tmp/10.21105.#{paper.journal_id}/*`
          sftp.upload("tmp/10.21105.#{paper.journal_id}.zip", "10.21105.#{paper.journal_id}.zip")
          puts "Uploading deposit for 10.21105.#{paper.journal_id}"

          # Clean up
          `rm -rf tmp/10.21105.#{paper.journal_id}*`

          # Update the paper
          paper.update_attribute(:archived, true)
        end
      end
    end
  end
end
