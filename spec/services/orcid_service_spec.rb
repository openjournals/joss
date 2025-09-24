require 'rails_helper'

RSpec.describe OrcidService, type: :service do
  let(:paper) { create(:accepted_paper) }
  let(:orcid_id) { '0000-0000-0000-0000' }
  let(:service) { described_class.new }

  before do
    allow(Rails.configuration).to receive(:orcid).and_return({
      'access_token' => 'test_token'
    })
  end

  describe '#post_work_to_author' do
    it 'returns false when orcid_id is blank' do
      result = service.post_work_to_author('', paper)
      expect(result).to be false
    end

    it 'returns false when paper doi is blank' do
      paper.update!(doi: nil)
      result = service.post_work_to_author(orcid_id, paper)
      expect(result).to be false
    end

    it 'makes HTTP request to ORCID API' do
      stub_request(:post, "https://api.orcid.org/v3.0/#{orcid_id}/works")
        .with(
          headers: {
            'Content-Type' => 'application/vnd.orcid+json',
            'Authorization' => 'Bearer test_token'
          }
        )
        .to_return(status: 201)

      result = service.post_work_to_author(orcid_id, paper)
      expect(result).to be true
    end

    it 'handles API errors gracefully' do
      stub_request(:post, "https://api.orcid.org/v3.0/#{orcid_id}/works")
        .to_return(status: 400)

      result = service.post_work_to_author(orcid_id, paper)
      expect(result).to be false
    end
  end

  describe '#post_review_to_reviewer' do
    let(:review_url) { 'https://github.com/test/repo/issues/123' }

    it 'returns false when orcid_id is blank' do
      result = service.post_review_to_reviewer('', paper, review_url)
      expect(result).to be false
    end

    it 'makes HTTP request to ORCID API' do
      stub_request(:post, "https://api.orcid.org/v3.0/#{orcid_id}/peer-reviews")
        .with(
          headers: {
            'Content-Type' => 'application/vnd.orcid+json',
            'Authorization' => 'Bearer test_token'
          }
        )
        .to_return(status: 201)

      result = service.post_review_to_reviewer(orcid_id, paper, review_url)
      expect(result).to be true
    end
  end

  describe '#build_work_data' do
    it 'builds correct work data structure' do
      work_data = service.send(:build_work_data, paper)
      
      expect(work_data['title']['title']['value']).to eq(paper.title)
      expect(work_data['journal-title']['value']).to eq('Journal of Open Source Software')
      expect(work_data['type']).to eq('software')
      expect(work_data['external-ids']['external-id'].first['external-id-type']).to eq('doi')
      expect(work_data['external-ids']['external-id'].first['external-id-value']).to eq(paper.doi)
    end
  end

  describe '#build_peer_review_data' do
    let(:review_url) { 'https://github.com/test/repo/issues/123' }

    it 'builds correct peer review data structure' do
      review_data = service.send(:build_peer_review_data, paper, review_url)
      
      expect(review_data['reviewer-role']).to eq('reviewer')
      expect(review_data['review-url']['value']).to eq(review_url)
      expect(review_data['review-type']).to eq('review')
      expect(review_data['review-group-id']).to eq('journal-of-open-source-software')
      expect(review_data['subject-external-identifier']['external-id-type']).to eq('doi')
      expect(review_data['subject-external-identifier']['external-id-value']).to eq(paper.doi)
    end
  end
end
