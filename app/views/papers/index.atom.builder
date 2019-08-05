atom_feed do |feed|
  feed.title(setting(:name))
  feed.updated(@papers[0].created_at) if @papers.length > 0

  @papers.each do |paper|
    next if paper.invisible?
    feed.entry(paper) do |entry|
      entry.title(paper.title)
      entry.state(paper.state)
      entry.tags(paper.author_tags.join(', '))
      entry.languages(paper.language_tags.join(', '))
      entry.archive_doi(paper.archive_doi)
      entry.software_version(paper.software_version)
      entry.content(formatted_body(paper), type: 'html')
    end
  end
end
