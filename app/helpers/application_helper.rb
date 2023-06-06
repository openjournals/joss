module ApplicationHelper
  include SettingsHelper
  include Pagy::Frontend

  def flash_class_for(flash_level)
    case flash_level
    when 'error'
      'alert-danger'
    when 'warning'
      'alert-warning'
    when 'notice'
      'alert-primary'
    else
      'alert-primary'
    end
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, class: class_name) do
      link_to link_text, link_path
    end
  end

  # Decide whether to show the 'update your profile' link
  def show_profile_banner?
    return false unless current_user
    return false if controller.action_name == "profile"

    if current_user.profile_complete?
      return false
    else
      return true
    end
  end

  def link_to_query(body, url, query)
    link_to(body, [url, query.to_param].join("?")).html_safe
  end

  def name_and_tagline
    "#{setting(:name)} (#{setting(:abbreviation)}) is #{setting(:tagline)}".html_safe
  end

  def avatar(username)
    return "https://github.com/#{username.sub(/^@/, "")}.png"
  end

  def paper_track_label(github_issue)
    id = github_issue.number
    paper = Paper.where('review_issue_id = ?', id).first
    return "" unless paper && paper.track
    content_tag(:span, paper.track.label, style: "padding: 3px; margin-right: 3px; border-radius: 2px; background-color: ##{paper.track.label_color}; color: #000000;")
  end

  def scope_link_for_issue(github_issue)
    id = github_issue.number
    paper = Paper.where('review_issue_id = ? OR meta_review_issue_id = ?', id, id).first
    
    return "" unless paper
    return url_for(paper)
  end

  def social_media_links
    links = []
    links << link_to("Twitter", "https://twitter.com/#{setting(:twitter)}", target: "_blank", title: "#{setting(:twitter)}").html_safe if setting(:twitter).present?
    links << link_to("Mastodon", setting(:mastodon_url), target: "_blank", rel: "me", title: "#{setting(:mastodon_url)}").html_safe if setting(:mastodon_url).present?
    links
  end
end
