if @paper.metadata['paper'].present?
  json.metadata @paper.metadata['paper']
end
json.state @paper.state
json.submitted_at @paper.created_at
if @paper.published?
  json.doi @paper.doi
  json.published_at @paper.accepted_at
  json.software_repository @paper.repository_url
  json.paper_review @paper.review_url
  json.pdf_url @paper.pdf_url
  json.software_archive @paper.clean_archive_doi
end
