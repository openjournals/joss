def gh
  @gh ||= Octokit::Client.new(access_token: ENV["GH_TOKEN"])
end

def reviews_repo
  @reviews_repo ||= Rails.application.settings["reviews"]
end

def get_open_issues
  gh.list_issues(reviews_repo , state: 'open', per_page: 300)
end

def get_issue(issue_id)
  gh.issue(reviews_repo, issue_id)
end

def update_issue(issue_id, options)
  gh.update_issue(reviews_repo, issue_id, options)
end

def get_editor(text)
  m = text.match(/\*\*Editor:\*\*\s*(@\S*|Pending)/i)
  m.nil? ? "" : m[1]
end

def get_reviewers(text)
  m = text.match(/Reviewers?:\*\*\s*(.+?)\r?\n/)
  m.nil? ? "" : m[1]
end

def get_version(text)
  m = text.match(/Version:\*\*\s*(\S*)\r?\n/)
  m.nil? ? "" : m[1]
end

def get_archive(text)
  m = text.match(/Archive:\*\*\s*(\S*)\r?\n/)
  m.nil? ? "" : m[1]
end

def get_repository_url(text)
  m = text.match(/Repository:\*\*.*>(\S*)<\/a>\r?\n/)
  m.nil? ? "" : m[1]
end

def get_submitting_author(text)
  m = text.match(/Submitting author:\*\*\s*(@\S*) (.*)\r?\n/)
  m.nil? ? [""] : [m[1], m[2]]
end

def get_header(body)
  body.match(/(.*)\*\*:warning: JOSS reduced service mode :warning:\*\*/m)[1]
end

def build_new_header(header)
  author_info = get_submitting_author(header)

  author_username = author_info[0]
  author_link = author_info[1]
  repository_url = get_repository_url(header)
  version = get_version(header)
  editor = get_editor(header)
  reviewers = get_reviewers(header)
  archive = get_archive(header)

  puts "      Submitting Author: #{author_username} - Extra info: #{author_link}"
  puts "      Repository URL: #{repository_url}"
  puts "      Version: #{version}"
  puts "      Editor: #{editor}"
  puts "      Reviewers: #{reviewers}"
  puts "      Archive: #{archive}"

  new_header = <<-NEWHEADER
**Submitting author:** <!--author-handle-->#{author_username}<!--end-author-handle--> #{author_link}
**Repository:** <!--target-repository-->#{repository_url}<!--end-target-repository-->
**Branch with paper.md** (empty if default branch): <!--branch--><!--end-branch-->
**Version:** <!--version-->#{version}<!--end-version-->
**Editor:** <!--editor-->#{editor}<!--end-editor-->
**Reviewers:** <!--reviewers-list-->#{reviewers}<!--end-reviewers-list-->
**Archive:** <!--archive-->#{archive}<!--end-archive-->
  NEWHEADER

  new_header
end

namespace :migration do
  desc "Migrate a single issue to use the new bot system"
  task :issue, [:issue_id] => :environment do |t, args|
    if args.issue_id.blank?
      puts "Missing issue id"
      puts "Use: rake migration:issue[issue-id]"
    else
      issue_id = args.issue_id
      issue = get_issue(issue_id)

      puts "!! Issue ##{issue_id} found: #{issue.title}"
      issue_body = issue.body
      header = get_header(issue_body)

      if header.start_with?("**Submitting author:** <!--author-handle-->")
        puts "    Issue already migrated! - Nothing done"
      elsif header.start_with?("**Submitting author:** @")
        puts "    Migrating info:"

        new_header = build_new_header(header)

        new_issue_body = issue_body.sub(header, "#{new_header}\n\n <!--\n#{header}\n-->\n\n")
        update_issue(issue_id, body: new_issue_body)

        puts "    Done!"
      else
        puts "    !! Error: unexpected issue header format - Nothing done"
      end
    end
  rescue Octokit::NotFound
    puts "No issue found with id #{args.issue_id} in #{reviews_repo}"
  end
end
