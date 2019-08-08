atom_feed do |feed|
  feed.title(setting(:name))
  feed.updated(@papers[0].created_at) if @papers.length > 0

  @papers.each do |paper|
    next if paper.invisible?
    feed.entry(paper) do |entry|
      entry.title(paper.title)
      entry.state(paper.state)
      entry.software_version(paper.software_version)
      entry.authors do |author|
        paper.authors.each_with_index do |a, i|
          sequence = i == 0 ? "first" : "additional"
          author.author("sequence"=>sequence) do |auth|
            auth.given_name a['given_name']
            auth.middle_name a['middle_name'] if a['middle_name']
            auth.last_name a['last_name']
            auth.affiliation a['affiliation']
            auth.orcid a['orcid'] if a['orcid']
          end
        end
      end
      if paper.accepted?
        entry.doi(paper.doi)
        entry.archive_doi(paper.archive_doi)
        entry.languages(paper.language_tags.join(', '))
        entry.pdf_url(paper.pdf_url)
        entry.tags(paper.author_tags.join(', '))
      end
    end
  end
end
