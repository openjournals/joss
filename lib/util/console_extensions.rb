module ConsoleExtensions
  def dat(review_issue_id)
    Paper.find_by_review_issue_id(review_issue_id)
  end
end
