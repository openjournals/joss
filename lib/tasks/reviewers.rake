namespace :reviewers do
  desc "Create reviewer records from existing paper reviewers"
  task populate_from_papers: :environment do
    puts "Creating reviewer records from existing papers..."
    
    # Get all unique reviewer GitHub usernames from papers
    reviewer_usernames = Paper.where.not(reviewers: []).pluck(:reviewers).flatten.uniq
    
    created_count = 0
    reviewer_usernames.each do |username|
      # Remove @ prefix if present
      clean_username = username.gsub(/^@/, '')
      
      # Create reviewer record if it doesn't exist
      reviewer = Reviewer.find_or_create_by(github_username: clean_username)
      if reviewer.persisted? && reviewer.previously_new_record?
        created_count += 1
        puts "Created reviewer: #{clean_username}"
      end
    end
    
    puts "Created #{created_count} new reviewer records"
    puts "Total reviewers in database: #{Reviewer.count}"
  end
  
  desc "List reviewers without ORCID authentication"
  task list_without_orcid: :environment do
    reviewers_without_orcid = Reviewer.left_joins(:user).where(users: { provider: nil }).or(
      Reviewer.left_joins(:user).where(users: { provider: ['', nil] })
    )
    
    puts "Reviewers without ORCID authentication (#{reviewers_without_orcid.count}):"
    reviewers_without_orcid.each do |reviewer|
      puts "- @#{reviewer.github_username}"
    end
  end
  
  desc "Link reviewers to existing ORCID-authenticated users"
  task link_to_orcid_users: :environment do
    orcid_users = User.where(provider: 'orcid')
    reviewers_without_orcid = Reviewer.left_joins(:user).where(users: { provider: nil }).or(
      Reviewer.left_joins(:user).where(users: { provider: ['', nil] })
    )
    
    puts "Linking reviewers to ORCID-authenticated users..."
    linked_count = 0
    
    reviewers_without_orcid.each do |reviewer|
      # Try to find a matching user by email or name
      matching_user = orcid_users.find do |user|
        (user.email.present? && user.email == reviewer.email) ||
        (user.github_username.present? && user.github_username == reviewer.github_username)
      end
      
      if matching_user
        reviewer.update!(user: matching_user)
        linked_count += 1
        puts "Linked @#{reviewer.github_username} to ORCID user #{matching_user.name} (#{matching_user.uid})"
      end
    end
    
    puts "Linked #{linked_count} reviewers to ORCID-authenticated users"
  end
end
