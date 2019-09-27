require 'net/ftp'

namespace :portico do
  desc "Deposit"
  task deposit: :environment do
    Paper.visible.each do |paper|
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

      # Upload to FTP server
      Net::FTP.open(ENV['PORTICO_HOST'], ENV['PORTICO_USERNAME'], ENV['PORTICO_PASSWORD']) do |ftp|
        ftp.putbinaryfile("tmp/10.21105.#{paper.joss_id}.zip")
        puts "Uploaded 10.21105.#{paper.joss_id}"
      end

      # Clean up
      `rm -rf tmp/10.21105.#{paper.joss_id}*`
    end
  end
end
