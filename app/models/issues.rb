class Issues
  def self.review_issue(paper)
    render :file => "/path/to/some/template.erb", :paper => paper
  end
end
