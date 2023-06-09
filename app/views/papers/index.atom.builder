atom_feed do |feed|
  url_params = {}
  [:q, :since, :language].each {|p| url_params.merge!(p => params[p]) if params{p}}
  feed.link(rel: 'first', type: "application/atom+xml", href: url_for(format: 'atom', only_path: false))
  feed.link(rel: 'next', type: "application/atom+xml", href: url_for(params: url_params, format: 'atom', page: @pagy.next, only_path: false)) if @pagy.next
  feed.link(rel: 'previous', type: "application/atom+xml", href: url_for(params: url_params, format: 'atom', page: @pagy.prev, only_path: false)) if @pagy.prev
  feed.link(rel: 'last', type: "application/atom+xml", href: url_for(params: url_params, format: 'atom', page: @pagy.pages, only_path: false))
  feed.title(Rails.application.settings["name"])
  feed.updated(@papers[0].accepted_at || @papers[0].created_at) if @papers.length > 0
  feed.author do |author|
    author.name(Rails.application.settings["name"])
    author.uri(Rails.application.settings["url"])
  end

  @papers.each do |paper|
    next if paper.invisible?
    feed.entry(paper, url: paper.seo_url, published: (paper.accepted? ? paper.accepted_at : paper.created_at)) do |entry|
      entry.title(paper.title)
      entry.content(type: "application/xml") do |content|
        entry.state(paper.state)
        entry.software_version(paper.software_version)
        entry.submitted_at(paper.created_at)
        if paper.accepted?
          entry.issue paper.issue
          entry.published_at(paper.accepted_at)
          entry.volume paper.volume
          entry.year paper.year
          entry.page paper.page
          entry.authors do |author|
            paper.metadata_authors.each_with_index do |a, i|
              sequence = i == 0 ? "first" : "additional"
              author.author("sequence" => sequence) do |auth|
                auth.given_name a['given_name']
                auth.middle_name a['middle_name'] if a['middle_name']
                auth.last_name a['last_name']
                auth.affiliation a['affiliation']
                auth.orcid a['orcid'] if a['orcid']
              end
            end
          end
          entry.doi(paper.doi)
          entry.archive_doi(paper.archive_doi_url)
          entry.languages(paper.language_tags.join(', '))
          entry.pdf_url(paper.seo_pdf_url)
          entry.tags(paper.author_tags.join(', '))
        end
      end
    end
  end
end
