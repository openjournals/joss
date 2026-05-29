namespace :stats do
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
