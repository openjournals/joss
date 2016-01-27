require 'rails_helper'

describe User do
  it { should have_many(:papers) }

  it "should initialize properly" do
    user = create(:user)

    assert !user.sha.nil?
    expect(user.sha.length).to eq(32)
    assert !user.admin?
  end

  it "should know how to parameterize itself properly" do
    user = create(:user)

    expect(user.sha).to eq(user.to_param)
  end

  it "should know how to create its ORCID id" do
    user = create(:user, :uid => "0000-0000-0000-1111")

    expect(user.orcid_url).to eq("http://orcid.org/#{user.uid}")
  end

  it "should know how to format its name" do
    user = create(:user, :uid => "0000-0000-0000-1111", :name => "Einstein, Albert")

    expect(user.nice_name).to eq("Albert Einstein")
  end
end
