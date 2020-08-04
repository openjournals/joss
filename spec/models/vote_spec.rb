require 'rails_helper'

describe Vote do
  before(:each) do
    Paper.destroy_all
    Vote.destroy_all
  end

  it "belongs_to a paper" do
    association = Vote.reflect_on_association(:paper)
    expect(association.macro).to eq(:belongs_to)
  end

  it "belongs_to an editor" do
    association = Vote.reflect_on_association(:editor)
    expect(association.macro).to eq(:belongs_to)
  end

  it "should only allow certain kinds of votes" do
    not_allowed_vote = build(:vote, kind: "say what mate?", paper: create(:paper), editor: create(:editor))

    expect { not_allowed_vote.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "should respond to instance method #in_scope?" do
    in_scope_vote = create(:in_scope_vote, editor: create(:editor), paper: create(:paper))

    assert in_scope_vote.in_scope?
  end

  it "should respond to instance method #out_of_scope?" do
    out_of_scope_vote = create(:out_of_scope_vote, editor: create(:editor), paper: create(:paper))

    assert out_of_scope_vote.out_of_scope?
  end

  it "should know how to look up a vote for an editor" do
    editor = create(:editor)
    editor2 = create(:editor)
    paper = create(:paper)
    create(:in_scope_vote, editor: editor, paper: paper)

    expect(Vote.has_vote_for?(paper, editor)).to be_a_kind_of(Vote)
    expect(Vote.has_vote_for?(paper, editor2)).to be_nil
  end
  

  it "should know about #in_scope and #out_of_scope" do
    submitted_paper = create(:paper, state: "submitted")

    3.times do
      create(:in_scope_vote, editor: create(:editor), paper: submitted_paper)
    end

    2.times do
      create(:out_of_scope_vote, editor: create(:editor), paper: submitted_paper)
    end
    
    expect(submitted_paper.votes.count).to eq(5)
    expect(submitted_paper.votes.in_scope.count).to eq(3)
    expect(submitted_paper.votes.out_of_scope.count).to eq(2)
  end

  it "should raise an exception when trying to create a second vote for the same editor" do
    editor = create(:editor)
    paper = create(:paper)
    create(:in_scope_vote, editor: editor, paper: paper)

    second_vote = build(:in_scope_vote, editor: editor, paper: paper)

    expect { second_vote.save! }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
