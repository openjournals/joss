require 'rails_helper'

RSpec.describe Reviewer, type: :model do
  describe 'validations' do
    it 'requires github_username' do
      reviewer = Reviewer.new
      expect(reviewer).not_to be_valid
      expect(reviewer.errors[:github_username]).to include("can't be blank")
    end

    it 'requires unique github_username' do
      Reviewer.create!(github_username: 'testuser')
      reviewer = Reviewer.new(github_username: 'testuser')
      expect(reviewer).not_to be_valid
      expect(reviewer.errors[:github_username]).to include('has already been taken')
    end

    it 'requires unique orcid_id when present' do
      Reviewer.create!(github_username: 'user1', orcid_id: '0000-0000-0000-0000')
      reviewer = Reviewer.new(github_username: 'user2', orcid_id: '0000-0000-0000-0000')
      expect(reviewer).not_to be_valid
      expect(reviewer.errors[:orcid_id]).to include('has already been taken')
    end
  end

  describe 'normalizations' do
    it 'removes @ prefix from github_username' do
      reviewer = Reviewer.create!(github_username: '@testuser')
      expect(reviewer.github_username).to eq('testuser')
    end
  end

  describe 'methods' do
    let(:reviewer) { Reviewer.create!(github_username: 'testuser', orcid_id: '0000-0000-0000-0000') }

    describe '#orcid_url' do
      it 'returns ORCID URL when orcid_id is present' do
        expect(reviewer.orcid_url).to eq('https://orcid.org/0000-0000-0000-0000')
      end

      it 'returns nil when orcid_id is blank' do
        reviewer.update!(orcid_id: nil)
        expect(reviewer.orcid_url).to be_nil
      end
    end

    describe '#display_name' do
      it 'returns name when present' do
        reviewer.update!(name: 'Test User')
        expect(reviewer.display_name).to eq('Test User')
      end

      it 'returns github_username when name is blank' do
        reviewer.update!(name: nil)
        expect(reviewer.display_name).to eq('testuser')
      end
    end

    describe '.find_or_create_by_github' do
      it 'creates new reviewer' do
        expect {
          Reviewer.find_or_create_by_github('newuser')
        }.to change(Reviewer, :count).by(1)
      end

      it 'finds existing reviewer' do
        existing = Reviewer.create!(github_username: 'existinguser')
        found = Reviewer.find_or_create_by_github('@existinguser')
        expect(found).to eq(existing)
      end
    end
  end
end
