FactoryBot.define do
  factory :issue_comment do
    paper { create(:review_pending_paper) }
    sequence(:login) { |n| "commenter_#{n}" }
    issue_id { paper.meta_review_issue_id || paper.review_issue_id || 1 }
    kind { "pre-review" }
    role { "none" }
    comment_url { "https://github.com/openjournals/joss-reviews-testing/issues/#{issue_id}#issuecomment-1" }
    commented_at { Time.now }
  end
end
