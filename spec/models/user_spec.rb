# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  admin            :boolean          default(FALSE)
#  email            :string
#  extra            :hstore
#  github_username  :string
#  name             :string
#  oauth_expires_at :string
#  oauth_token      :string
#  provider         :string
#  sha              :string
#  uid              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email)
#  index_users_on_name   (name)
#  index_users_on_sha    (sha)
#
require 'rails_helper'

describe User do
  it "has many papers" do
    association = User.reflect_on_association(:papers)
    expect(association.macro).to eq(:has_many)
  end

  it "should initialize properly" do
    user = create(:user)

    assert !user.sha.nil?
    expect(user.sha.length).to eq(32)
    assert !user.admin?
  end

  it "should know who the editors are" do
    user = create(:user)
    editor = create(:editor, user: user)

    expect(user.editor).to eq(editor)
    expect(user.editor?).to eq(true)
    expect(user.aeic?).to eq(false)
  end

  it "should know who the associate editors in chief are" do
    user = create(:user)
    editor = create(:board_editor, user: user)

    expect(user.editor).to eq(editor)
    expect(user.editor?).to eq(true)
    expect(user.aeic?).to eq(true)
  end

  it "should know how to parameterize itself properly" do
    user = create(:user)

    expect(user.sha).to eq(user.to_param)
  end

  it "should know how to create its ORCID id" do
    user = create(:user, uid: "0000-0000-0000-1111")

    expect(user.orcid_url).to eq("http://orcid.org/#{user.uid}")
  end

  it "should know how to format its name" do
    user = create(:user, uid: "0000-0000-0000-1111", name: "Einstein, Albert")

    expect(user.nice_name).to eq("Albert Einstein")
  end

  it "should know whether it's profile is complete" do
    complete_profile_user = create(:user, email: "a@b.com", github_username: "@foo")
    user_without_email = create(:user, email: nil)
    user_without_github_username = create(:user, github_username: nil)

    assert complete_profile_user.profile_complete?
    assert !user_without_email.profile_complete?
    assert !user_without_github_username.profile_complete?
  end
end
