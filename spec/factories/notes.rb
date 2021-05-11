FactoryBot.define do
  factory :note do
    editor { create(:editor) }
    paper { create(:review_pending_paper) }
    sequence(:comment) {|n| "Testing editor notes #{n}" }
  end
end