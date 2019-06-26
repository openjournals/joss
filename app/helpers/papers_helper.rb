module PapersHelper
  def selected_class(tab_name)
    if controller.action_name == tab_name
      "selected"
    end
  end

  def badge_link(paper)
    if paper.accepted?
      return paper.cross_ref_doi_url
    else
      return paper.review_url
    end
  end

  def submittor_avatar(paper)
    if username = paper.submitting_author.github_username
      return "https://github.com/#{username.sub(/^@/, "")}.png"
    else
      return ""
    end
  end

  def submittor_github(paper)
    if username = paper.submitting_author.github_username
      return "https://github.com/#{username.sub(/^@/, "")}"
    else
      return "https://github.com"
    end
  end

  def formatted_body(paper, length=nil)
    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::SanitizationFilter
    ]

    if length
      body = paper.body.truncate(length, separator: /\s/)
    else
      body = paper.body
    end

    result = pipeline.call(body)
    result[:output].to_s.html_safe
  end

  def paper_types
    Rails.application.settings["paper_types"]
  end
end
