FactoryGirl.define do
  factory :user do
    provider 'orcid'
    name 'Doe, John'
    created_at { Time.now }
    email 'john@apple.com'
    uid '0000-0000-0000-1234'
    github_username '@foobar'

    factory :admin_user do
      admin true
    end

    factory :no_email_user do
      email nil
    end
  end
end
