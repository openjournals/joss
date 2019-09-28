require 'net/ftp'

namespace :portico do
  desc "Deposit"
  task deposit: :environment do
    Paper.visible.not_archived.each do |paper|
      # Upload to FTP server
      Net::FTP.open(ENV['PORTICO_HOST'], ENV['PORTICO_USERNAME'], ENV['PORTICO_PASSWORD']) do |ftp|
        if ftp.list("10.21105.#{paper.joss_id}.zip").any?
          puts "Deposit already exists for 10.21105.#{paper.joss_id}"
        else
          crossref_file = "https://github.com/#{Rails.application.settings["papers_repo"]}/raw/master/#{paper.joss_id}/10.21105.#{paper.joss_id}.crossref.xml"
          pdf_file = "https://github.com/#{Rails.application.settings["papers_repo"]}/raw/master/#{paper.joss_id}/10.21105.#{paper.joss_id}.pdf"

          files_to_download = [crossref_file, pdf_file]

          # Create folder
          `mkdir tmp/10.21105.#{paper.joss_id}`

          # Download the files into this folder
          files_to_download.each do |file|
            `cd tmp/10.21105.#{paper.joss_id} && { curl -L -O #{file} ; cd -; }`
          end

          # Zip the folder
          `zip tmp/10.21105.#{paper.joss_id}.zip tmp/10.21105.#{paper.joss_id}/*`
          ftp.putbinaryfile("tmp/10.21105.#{paper.joss_id}.zip")
          puts "Uploading deposit for 10.21105.#{paper.joss_id}"

          # Clean up
          `rm -rf tmp/10.21105.#{paper.joss_id}*`

          # Update the paper
          paper.update_attribute(:archived, true)
        end
      end
    end
  end
end
