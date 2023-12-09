module HomeHelper
  def pretty_labels_for(paper)
    if paper.labels.empty?
      return nil unless paper.track
      concat content_tag(:span, paper.track.label, style: "padding: 3px; margin-right: 3px; border-radius: 2px; background-color: ##{paper.track.label_color}; color: #000000;")
    end
    
    capture do
      paper.labels.each do |label, colour|
        if label == "paused"
          concat content_tag(:span, label, style: "padding: 3px; margin-right: 3px; border-radius: 2px; background-color: ##{colour}; color: white;")
        elsif label == "recommend-accept"
          concat content_tag(:span, label, style: "padding: 3px; margin-right: 3px; border-radius: 2px; background-color: ##{colour}; color: #000000;")
        elsif label == "query-scope"
          concat content_tag(:span, label, style: "padding: 3px; margin-right: 3px; border-radius: 2px; background-color: ##{colour}; color: #000000;")
        elsif label == "waitlisted"
          concat content_tag(:span, label, style: "padding: 3px; margin-right: 3px; border-radius: 2px; background-color: ##{colour}; color: #000000;")
        elsif label.start_with?("Track: ")
          concat content_tag(:span, label, style: "padding: 3px; margin-right: 3px; border-radius: 2px; background-color: ##{colour}; color: #000000;")
        end
      end
    end
  end

  def current_class?(test_path)
    return 'tabnav-tab selected' if request.path == test_path
    'tabnav-tab'
  end

  def vote_summary(paper, votes_by_paper)
    if paper.labels.keys.include?("query-scope")
      summary = ""
      vote = votes_by_paper[paper.id]
      summary = if vote.nil?
        content_tag(:small, "👍(#{paper.in_scope_votes.count}) / 👎 (#{paper.votes.out_of_scope.count})")
      elsif vote.in_scope?
        content_tag(:small, "👍(#{paper.in_scope_votes.count}) / <span class='grey-emoji'>👎</span> (#{paper.out_of_scope_votes.count})".html_safe)
      elsif vote.out_of_scope?
        content_tag(:small, "<span class='grey-emoji'>👍</span>(#{paper.in_scope_votes.count}) / 👎 (#{paper.out_of_scope_votes.count})".html_safe)
      elsif vote.comment?
        content_tag(:small, "<span class='grey-emoji'>👍</span>(#{paper.in_scope_votes.count}) / <span class='grey-emoji'>👎</span> (#{paper.out_of_scope_votes.count})".html_safe)
      end
      summary.html_safe
    else
      'OK'
    end
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

  def sort_activity(sort_order)
    track_param = params[:track_id].present? ? "track_id=#{params[:track_id]}&" : ""
    request_path = "#{request.path}?#{track_param}"

    capture do
      if sort_order == "active-desc"
        concat(link_to octicon("chevron-up"), "#{request_path}order=active-asc")
      elsif sort_order == "active-asc"
        concat(link_to octicon("chevron-down"), "#{request_path}order=active-desc")
      else
        concat(link_to octicon("chevron-down"), "#{request_path}order=active-desc")
      end
    end
  end

  def comment_activity(paper)
    begin
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
    rescue 
      return "Error returning latest status"
    end
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
end
