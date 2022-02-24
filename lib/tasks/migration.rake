def gh
  @gh ||= GITHUB
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

def get_managing_eic(text)
  m = text.match(/Managing EiC:\*\*\s*(.*)\r?\n/)
  m.nil? ? "" : m[1]
end

def get_header(body)
  m = body.match(/(.*)## Status/m)
  m.nil? ? nil : m[1]
end

def build_new_header(header, issue_type)
  author_info = get_submitting_author(header)

  author_username = author_info[0]
  author_link = author_info[1]
  repository_url = get_repository_url(header)
  version = get_version(header)
  editor = get_editor(header)
  reviewers = get_reviewers(header)
  archive = get_archive(header)
  eic = get_managing_eic(header)

  puts "      Submitting Author: #{author_username} - Extra info: #{author_link}"
  puts "      Repository URL: #{repository_url}"
  puts "      Version: #{version}"
  puts "      Editor: #{editor}"
  puts "      Reviewers: #{reviewers}"
  puts "      Archive: #{archive}" if issue_type == "review"
  puts "      Managing EiC: #{eic}" if issue_type == "pre-review"

  if issue_type == "pre-review"
    new_header = <<-NEWHEADERMETA
**Submitting author:** <!--author-handle-->#{author_username}<!--end-author-handle--> #{author_link}
**Repository:** <!--target-repository-->#{repository_url}<!--end-target-repository-->
**Branch with paper.md** (empty if default branch): <!--branch--><!--end-branch-->
**Version:** <!--version-->#{version}<!--end-version-->
**Editor:** <!--editor-->#{editor}<!--end-editor-->
**Reviewers:** <!--reviewers-list-->#{reviewers}<!--end-reviewers-list-->
**Managing EiC:** #{eic}
    NEWHEADERMETA
  elsif issue_type == "review"
    new_header = <<-NEWHEADER
**Submitting author:** <!--author-handle-->#{author_username}<!--end-author-handle--> #{author_link}
**Repository:** <!--target-repository-->#{repository_url}<!--end-target-repository-->
**Branch with paper.md** (empty if default branch): <!--branch--><!--end-branch-->
**Version:** <!--version-->#{version}<!--end-version-->
**Editor:** <!--editor-->#{editor}<!--end-editor-->
**Reviewers:** <!--reviewers-list-->#{reviewers}<!--end-reviewers-list-->
**Archive:** <!--archive-->#{archive}<!--end-archive-->
    NEWHEADER
  else
    new_header = nil
  end

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

      puts "-- Issue ##{issue_id} found: #{issue.title}"

      issue_type = "pre-review" if issue.title.match(/\[PRE REVIEW\]/)
      issue_type = "review" if issue.title.match(/\[REVIEW\]/)

      issue_body = issue.body
      header = get_header(issue_body)

      if issue_type.nil?
        puts "    !! Error: Issue is not a [REVIEW] or [PRE-REVIEW] - Nothing done"
        exit(0)
      end

      if header.nil?
        puts "    !! Error: Can't find header - Nothing to do"
        exit(0)
      end

      if header.start_with?("**Submitting author:** <!--author-handle-->")
        puts "    Issue already migrated! - Nothing done"
      elsif header.start_with?("**Submitting author:** @")
        puts "    Migrating info:"
        new_header = build_new_header(header, issue_type)
        new_issue_body = issue_body.sub(header, "#{new_header}\n\n <!--\n#{header}\n-->\n\n")
        update_issue(issue_id, body: new_issue_body)
        puts "    Done!"
      else
        puts "    !! Error: unexpected issue header format - Nothing done"
      end
    end
  rescue Octokit::NotFound
    puts "--!! No issue found with id #{args.issue_id} in #{reviews_repo}"
  end

  desc "Migrate all open issues to the new bot system"
    task all_issues: :environment do
      open_issues = get_open_issues
      puts "#{open_issues.size} issues found!\n"
      open_issues.each_with_index do |issue, i|

        issue_id = issue.number
        puts "-- #{i+1}) Issue ##{issue_id}: #{issue.title}\n"

        issue_type = "pre-review" if issue.title.match(/\[PRE REVIEW\]/)
        issue_type = "review" if issue.title.match(/\[REVIEW\]/)

        issue_body = issue.body
        header = get_header(issue_body)

        if issue_type.nil?
          puts "    !! Error: Issue is not a [REVIEW] or [PRE-REVIEW] - Nothing done"
          next
        end

        if header.nil?
          puts "    !! Error: Can't find header - Nothing to do"
          next
        end

        if header.start_with?("**Submitting author:** <!--author-handle-->")
          puts "    Issue already migrated! - Nothing done"
        elsif header.start_with?("**Submitting author:** @")
          puts "    Migrating info:"
          new_header = build_new_header(header, issue_type)
          new_issue_body = issue_body.sub(header, "#{new_header}\n\n <!--\n#{header}\n-->\n\n")
          update_issue(issue_id, body: new_issue_body)
          puts "    Done!"
        else
          puts "    !! Error: unexpected issue header format - Nothing done"
        end
      end
    rescue Octokit::NotFound
      puts "--!! No issue found with id #{args.issue_id} in #{reviews_repo}"
    end

  namespace :dry_run do
    desc "Dry run of the migration of a single issue to the new bot system"
    task :issue, [:issue_id] => :environment do |t, args|
      if args.issue_id.blank?
        puts "Missing issue id"
        puts "Use: rake migration:dry_run:issue[issue-id]"
      else
        issue_id = args.issue_id
        issue = get_issue(issue_id)

        puts "-- Issue ##{issue_id} found: #{issue.title}\n"

        issue_type = "pre-review" if issue.title.match(/\[PRE REVIEW\]/)
        issue_type = "review" if issue.title.match(/\[REVIEW\]/)

        issue_body = issue.body
        header = get_header(issue_body)

        if issue_type.nil?
          puts "    !! Error: Issue is not a [REVIEW] or [PRE-REVIEW] - Nothing to do"
          exit(0)
        end

        if header.nil?
          puts "    !! Error: Can't find header - Nothing to do"
          exit(0)
        end

        if header.start_with?("**Submitting author:** <!--author-handle-->")
          puts "    Issue already migrated! - Nothing to do"
        elsif header.start_with?("**Submitting author:** @")
          puts "    Information extracted:"

          new_header = build_new_header(header, issue_type)

          puts "\n    New header would be changed to:"
          puts "\n#{new_header}\n "
        else
          puts "    !! Error: unexpected issue header format - Nothing to do"
        end
      end
    rescue Octokit::NotFound
      puts "--!! No issue found with id #{args.issue_id} in #{reviews_repo}"
    end


    desc "Dry run of the migration of all open issues to the new bot system"
    task all_issues: :environment do

      open_issues = get_open_issues
      puts "#{open_issues.size} issues found!\n"
      open_issues.each_with_index do |issue, i|

        issue_id = issue.number
        puts "-- #{i+1}) Issue ##{issue_id}: #{issue.title}\n"

        issue_type = "pre-review" if issue.title.match(/\[PRE REVIEW\]/)
        issue_type = "review" if issue.title.match(/\[REVIEW\]/)

        issue_body = issue.body
        header = get_header(issue_body)

        if issue_type.nil?
          puts "    !! Error: Issue is not a [REVIEW] or [PRE-REVIEW] - Nothing to do"
          next
        end

        if header.nil?
          puts "    !! Error: Can't find header - Nothing to do"
          next
        end

        if header.start_with?("**Submitting author:** <!--author-handle-->")
          puts "    Issue already migrated! - Nothing to do"
        elsif header.start_with?("**Submitting author:** @")
          puts "    Information extracted:"

          new_header = build_new_header(header, issue_type)

          puts "\n    New header would be changed to:"
          puts "\n#{new_header}\n "
        else
          puts "    !! Error: unexpected issue header format - Nothing to do"
        end
      end
    rescue Octokit::NotFound
      puts "--!! No issue found with id #{args.issue_id} in #{reviews_repo}"
    end
  end
end
