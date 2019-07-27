FactoryBot.define do
  factory :paper do
    title             'arfon / fidgit'
    body              'An ungodly union of GitHub and Figshare http://fidgit.arfon.org'
    repository_url    'http://github.com/arfon/fidgit'
    archive_doi       'https://doi.org/10.0001/zenodo.12345'
    software_version  'v1.0.0'
    submitting_author { create(:user) }

    created_at  { Time.now }
    updated_at  { Time.now }

    factory :paper_with_sha do
      sha '48d24b0158528e85ac7706aecd8cddc4'
    end

    factory :submitted_paper do
      state 'submitted'
    end

    factory :submitted_paper_with_sha do
      sha '48d24b0158528e85ac7706aecd8cddc4'
      state 'submitted'
    end

    factory :review_pending_paper do
      sha '48d24b0158528e85ac7706aecd8cddc4'
      state 'review_pending'
      meta_review_issue_id 100
    end

    factory :under_review_paper do
      sha '48d24b0158528e85ac7706aecd8cddc4'
      state 'under_review'
      meta_review_issue_id 100
      review_issue_id 101
    end
  end
end
