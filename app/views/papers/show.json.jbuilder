json.title @paper.title
json.state @paper.state
json.submitted_at @paper.created_at
if @paper.published?
  json.doi @paper.doi
  json.published_at @paper.accepted_at
  json.volume @paper.volume
  json.issue @paper.issue
  json.year @paper.year
  json.page @paper.page
  json.authors @paper.metadata_authors
  json.editor @paper.metadata_editor
  if @paper.editor
    json.editor_name @paper.editor.full_name
    json.editor_url @paper.editor.url if @paper.editor.url
    json.editor_orcid @paper.editor.orcid
  end
  json.reviewers @paper.metadata_reviewers
  json.languages @paper.language_tags.join(', ')
  json.tags @paper.author_tags.join(', ')
  json.software_repository @paper.repository_url
  json.paper_review @paper.review_url
  json.pdf_url @paper.seo_pdf_url
  json.software_archive @paper.clean_archive_doi
end
