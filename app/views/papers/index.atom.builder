atom_feed do |feed|
  feed.title('The Journal of Open Source Software')
  feed.updated(@papers[0].created_at) unless @papers.empty?

  @papers.each do |paper|
    feed.entry(paper) do |entry|
      entry.title(paper.title)
      entry.state(paper.state)
      entry.archive_doi(paper.archive_doi)
      entry.software_version(paper.software_version)
      entry.content(formatted_body(paper), type: 'html')
    end
  end
end
