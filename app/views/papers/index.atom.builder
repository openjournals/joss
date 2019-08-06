atom_feed do |feed|
  feed.title(setting(:name))
  feed.updated(@papers[0].created_at) if @papers.length > 0

  @papers.each do |paper|
    next if paper.invisible?
    feed.entry(paper) do |entry|
      entry.title(paper.title)
      entry.state(paper.state)
      entry.software_version(paper.software_version)
      if paper.accepted?
        entry.archive_doi(paper.archive_doi)
        entry.languages(paper.language_tags.join(', '))
        entry.pdf_url(paper.pdf_url)
        entry.tags(paper.author_tags.join(', '))
      end
    end
  end
end
