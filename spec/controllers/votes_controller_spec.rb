require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  it "LOGGED IN, not blank, responds with success" do
    editor = create(:editor, login: "josseditor")
    editing_user = create(:user, editor: editor)
    paper = create(:submitted_paper)

    allow(controller).to receive_message_chain(:current_user).and_return(editing_user)
    vote_count = paper.votes.count

    vote_params = { vote: { comment: "This is in scope!"}, 
                    commit: "Vote as in scope 👍", 
                    paper_id: paper.sha }

    post :create, params: vote_params
    expect(response).to be_redirect # as it's created the thing
    expect(paper.votes.count).to eq(vote_count + 1)
  end

  it "LOGGED IN, NO COMMENT, responds with failure" do
    editor = create(:editor, login: "josseditor")
    editing_user = create(:user, editor: editor)
    paper = create(:submitted_paper)

    allow(controller).to receive_message_chain(:current_user).and_return(editing_user)
    vote_count = paper.votes.count

    vote_params = { vote: { comment: ""}, 
                    commit: "Vote as in scope 👍", 
                    paper_id: paper.sha }

    post :create, params: vote_params
    expect(paper.votes.count).to eq(vote_count) # No new votes
  end

  it "LOGGED IN responds with success should an additional vote (but destroy the first)" do
    editor = create(:editor, login: "josseditor")
    editing_user = create(:user, editor: editor)
    paper = create(:submitted_paper)
    original_vote = create(:in_scope_vote, paper: paper, editor: editor)

    allow(controller).to receive_message_chain(:current_user).and_return(editing_user)
    vote_count = paper.votes.count

    vote_params = { vote: { comment: "This is out of scope!"}, 
                    commit: "Vote as out of scope 👎", 
                    paper_id: paper.sha }

    post :create, params: vote_params
    expect(response).to be_redirect # as it's created the thing
    expect(paper.votes.count).to eq(vote_count)
    expect(Vote.find_by_id(original_vote.id)).to be_nil
  end  
end
