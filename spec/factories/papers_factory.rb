FactoryBot.define do
  factory :paper do
    title             { 'arfon / fidgit' }
    body              { 'An ungodly union of GitHub and Figshare http://fidgit.arfon.org' }
    repository_url    { 'http://github.com/arfon/fidgit' }
    archive_doi       { 'https://doi.org/10.0001/zenodo.12345' }
    software_version  { 'v1.0.0' }
    submitting_author { create(:user) }
    submission_kind   { 'new' }
    suggested_editor  { '@editor' }

    created_at  { Time.now }
    updated_at  { Time.now }

    factory :paper_with_sha do
      sha { '48d24b0158528e85ac7706aecd8cddc4' }
    end

    paper_metadata = { 'paper' => { 'languages' => ['Ruby', 'Rust'],
                                    'editor' => '@arfon',
                                    'title' => 'arfon / fidgit',
                                    'reviewers' => ['@jim', '@jane'],
                                    'authors' => [{'given_name' =>  'Mickey', 'last_name' => 'Mouse', 'orcid' => '0000-0002-7736-0000'},
                                                  {'given_name' => 'Walt', 'middle_name' => 'Elias', 'last_name' => 'Disney', 'orcid' => '0000-0002-7736-000X'}]}}
    factory :accepted_paper do
      metadata { paper_metadata }
      state { 'accepted' }
      accepted_at { Time.now }
      review_issue_id { 0 }
      doi { '10.21105/jose.00000' }
    end

    factory :submitted_paper do
      state { 'submitted' }
    end

    factory :resubmission_paper do
      submission_kind   { 'resubmission' }
    end

    factory :rejected_paper do
      state { 'rejected' }
    end

    factory :retracted_paper do
      metadata { paper_metadata }
      state { 'retracted' }
      accepted_at { Time.now }
      review_issue_id { 0 }
      doi { '10.21105/jose.00000' }
    end

    factory :submitted_paper_with_sha do
      sha { '48d24b0158528e85ac7706aecd8cddc4' }
      state { 'submitted' }
    end

    factory :review_pending_paper do
      sha { '48d24b0158528e85ac7706aecd8cddc4' }
      state { 'review_pending' }
      meta_review_issue_id { 100 }
    end

    factory :under_review_paper do
      sha { '48d24b0158528e85ac7706aecd8cddc4' }
      state { 'under_review' }
      meta_review_issue_id { 100 }
      review_issue_id { 101 }
    end
  end
end
