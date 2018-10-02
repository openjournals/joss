module HomeHelper

  def current_class?(test_path)
    return 'nav-link active' if request.path == test_path
    'nav-link'
  end

  def last_comment_for(paper)
    return "No recent comments" unless paper.activities['issues']
    comments = paper.activities['issues']['comments']
    last_comment = comments.sort_by {|c| c['commented_at']}.last

    if last_comment
      "#{github_user(last_comment['author'])} #{time_ago_in_words(last_comment ['commented_at'])} ago. #{comment_link(last_comment)}".html_safe
    else
      return "No recent comments"
    end
  end

  def commenters_for(paper)

  end

  def comment_link(comment)
    link_to("View comment &rarr;".html_safe, comment['comment_url'], :target => "_blank")
  end

  def github_user(username)
    link_to("@#{username}", "https://github.com/#{username.gsub('@', '')}")
  end

  def activites_shortcut_for(paper)
    activities = paper.activities['issues']
    comments = activities['pre-review']['comments'] + activities['review']['comments']
    "Last comment by @arfon 3 hours ago (expand)"
  end

  def linked_reviewers(paper)
    paper.reviewers.map { |reviewer| github_user(reviewer.gsub('@', '')) }.join(', ').html_safe
  end
end
