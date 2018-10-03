module HomeHelper
  def current_class?(test_path)
    return 'nav-link active' if request.path == test_path
    'nav-link'
  end

  def card_activity(paper)
    return "No activity" if paper.activities['issues']['commenters'].empty?
    capture do
      if !paper.activities['issues']['comments'].empty?
        concat content_tag(:strong, "Recent comments", :style => "padding-bottom: 5px;")
        paper.activities['issues']['comments'].each do |comment|
          concat(content_tag(:p, truncate(comment['comment'], :length => 120), :style => "padding: 0px; margin-bottom: 0px;"))
          concat(content_tag(:p, "#{time_ago_in_words(comment['commented_at']).capitalize} ago (@#{comment['author']}). #{comment_link(comment)}".html_safe, :style => "padding: 0px; margin: 0px 0px 10px 0px; font-style: italic;"))
        end
      end
    end
  end

  def last_comment_for(paper)
    return "No recent comments" unless paper.activities['issues']
    comments = paper.activities['issues']['comments']
    last_comment = comments.sort_by {|c| c['commented_at']}.last

    if last_comment
      "#{github_user(last_comment['author'])} #{time_ago_in_words(last_comment ['commented_at'])} ago,  #{comment_link(last_comment)}".html_safe
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
