module PapersHelper
  def selected_class(tab_name)
    'selected' if controller.action_name == tab_name
  end

  def badge_link(paper)
    if paper.accepted?
      return paper.cross_ref_doi_url
    else
      return paper.review_url
    end
  end

  def formatted_body(paper, length = nil)
    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::SanitizationFilter
    ]

    body = if length
             paper.body.truncate(length, separator: /\s/)
           else
             paper.body
           end

    result = pipeline.call(body)
    result[:output].to_s.html_safe
  end
end
