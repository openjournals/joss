FactoryGirl.define do
  factory :paper do
    title           'arfon / fidgit'
    body            'An ungodly union of GitHub and Figshare http://fidgit.arfon.org'
    repository_url  'http://github.com/arfon/fidgit'
    archive_doi     'http://dx.doi.org/10.0001/zenodo.12345'

    created_at  { Time.now }
    updated_at  { Time.now }

    factory :paper_with_sha do
      sha '48d24b0158528e85ac7706aecd8cddc4'
    end

    factory :submitted_paper do
      state 'submitted'
    end
  end
end
