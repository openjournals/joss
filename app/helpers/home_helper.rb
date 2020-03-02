module HomeHelper
  # How many papers should we show for an editor on the dashboard?
  def in_progress_for_editor(papers)
    ignored_state = "paused"
    ignored_count = 0
    papers.each do |p|
      if p.labels.any? && p.labels.keys.include?(ignored_state)
        ignored_count += 1
      end
    end

    if ignored_count > 0
      return "#{papers.count - ignored_count} <span class='small font-italic'>(+ #{ignored_count} paused)</span>".html_safe
    else
      return "#{papers.count}"
    end
  end

  def count_without_ignored(papers)
    ignored_state = "paused"
    ignored_count = 0
    papers.each do |p|
      if p.labels.any? && p.labels.keys.include?(ignored_state)
        ignored_count += 1
      end
    end

    return papers.count - ignored_count
  end

  def pretty_labels_for(paper)
    return nil unless paper.labels.any?

    capture do
      paper.labels.each do |label, colour|
        if label == "paused"
          concat content_tag(:span, label, style: "padding: 3px; margin-right: 3px; border-radius: 2px; background-color: ##{colour}; color: white;")
        elsif label == "recommend-accept"
          concat content_tag(:span, label, style: "padding: 3px; margin-right: 3px; border-radius: 2px; background-color: ##{colour}; color: white;")
        end
      end
    end
  end

  def current_class?(test_path)
    return 'tabnav-tab selected' if request.path == test_path
    'tabnav-tab'
  end

  def review_issue_links(paper)
    capture do
      if paper.meta_review_issue_id
        concat(link_to paper.meta_review_issue_id, paper.meta_review_url)
      else
        concat("–")
      end

      concat(" / ")

      if paper.review_issue_id
        concat(link_to paper.review_issue_id, paper.review_url)
      else
        concat("–")
      end
    end
  end

  def checklist_activity(paper)
    return "No activity" if paper.activities.empty?
    return "No activity" if paper.activities['issues']['commenters'].empty?

    capture do
      if !paper.activities['issues']['comments'].empty?
        if paper.activities['issues']['last_edits'] && paper.activities['issues']['last_edits'].keys.any?
          non_whedon_activities = paper.activities['issues']['last_edits'].select {|user, time| user != "whedon"}
          return "No activity" if non_whedon_activities.empty?
          user, time = non_whedon_activities.first
          concat(content_tag(:span, image_tag(avatar(user), size: "24x24", class: "avatar", title: user), class: "activity-avatar"))
          concat(content_tag(:span, style: "") do
            concat(content_tag(:span, "#{time_ago_in_words(time)} ago".html_safe, class: "time"))
          end)
        else
          return "No activity"
        end
      end
    end
  end

  def sort_icon(sort_order)
    capture do
      if sort_order == "desc"
        concat(link_to octicon("chevron-up"), "#{request.path}?order=asc")
      elsif sort_order == "asc"
        concat(link_to octicon("chevron-down"), "#{request.path}?order=desc")
      end
    end
  end

  def comment_activity(paper)
    return "No activity" if paper.activities.empty?
    return "No activity" if paper.activities['issues']['commenters'].empty?
    capture do
      comment = paper.activities['issues']['comments'].first
      concat(content_tag(:span, image_tag(avatar(comment['author']), size: "24x24", class: "avatar", title: comment['author']), class: "activity-avatar"))
      concat(content_tag(:span, style: "") do
        concat(content_tag(:span, "#{time_ago_in_words(comment['commented_at'])} ago".html_safe, class: "time"))
        concat(content_tag(:span, "#{comment_link(comment)}".html_safe, class: "comment-link"))
      end)
    end
  end

  def card_activity(paper)
    return "No activity" if paper.activities.empty?
    return "No activity" if paper.activities['issues']['commenters'].empty?
    capture do
      if !paper.activities['issues']['comments'].empty?
        if paper.activities['issues']['last_edits'] && paper.activities['issues']['last_edits'].keys.any?
          concat content_tag(:strong, "Recent activity", style: "padding-bottom: 5px;")
          paper.activities['issues']['last_edits'].each do |user,time|
            concat(content_tag(:p, "Checklist edit by #{user}, #{time_ago_in_words(time)} ago", style: "padding: 0px; margin: 0px 0px 10px 0px;"))
          end
        end
        concat content_tag(:strong, "Recent comments", style: "padding-bottom: 5px;")
        paper.activities['issues']['comments'].each do |comment|
          concat(content_tag(:p, truncate(comment['comment'], length: 120), style: "padding: 0px; margin-bottom: 0px;"))
          concat(content_tag(:p, "#{time_ago_in_words(comment['commented_at']).capitalize} ago (@#{comment['author']}). #{comment_link(comment)}".html_safe, style: "padding: 0px; margin: 0px 0px 10px 0px; font-style: italic;"))
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

  def stale_link
    link_to("Most stale".html_safe, "#{request.path}?order=asc")
  end

  def fresh_link
    link_to("Least stale".html_safe, "#{request.path}?order=desc")
  end

  def comment_link(comment)
    link_to("View comment &raquo;".html_safe, comment['comment_url'], target: "_blank", title: comment['comment'])
  end

  def github_user_link(username)
    "https://github.com/#{username.gsub('@', '')}"
  end

  def github_user(username)
    link_to("@#{username}", github_user_link(username))
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
