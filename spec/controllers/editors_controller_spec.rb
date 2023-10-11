require 'rails_helper'

RSpec.describe EditorsController, type: :controller do
  let(:current_user) { create(:user, editor: create(:board_editor)) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when not logged in" do
    let(:current_user) { nil }
    it "redirects to root with a login message" do
      get :index
      expect(response).to redirect_to root_path
      expect(flash[:error]).to eql "Please login first"
    end

    it "should allow the lookup of an editor" do
      editor = create(:editor)
      get :lookup, params: {login: editor.login }

      expect(JSON.parse(response.body)['name']).to eq('Person McEditor')
      expect(JSON.parse(response.body)['url']).to eq('http://placekitten.com')
    end
  end

  context "when logged in as a simple user" do
    let(:current_user) { create(:user) }
    it "redirects to the root" do
      get :index
      expect(response).to redirect_to root_path
    end

    it "sets the flash" do
      get :index
      expect(flash[:error]).to eql "You are not permitted to view that page"
    end
  end

  context "when logged in as an editor" do
    let(:current_user) { create(:user, editor: create(:editor)) }
    it "redirects to the root" do
      get :index
      expect(response).to redirect_to root_path
    end

    it "sets the flash" do
      get :index
      expect(flash[:error]).to eql "You are not permitted to view that page"
    end
  end

  describe "#index" do
    it "assigns editors to @active_editors and @emeritus_editors" do
      track = create(:track)
      board = track.aeics.first
      editor = create(:editor, track_ids: [track.id])
      emeritus = create(:editor, kind: "emeritus")
      create(:editor, kind: "pending", track_ids: [track.id])
      get :index

      expect(@controller.view_assigns["active_editors"]).to eq([current_user.editor, board, editor])
      expect(@controller.view_assigns["emeritus_editors"]).to eq([emeritus])
    end

    it "assigns grouped availability information" do
      get :index
      expect(@controller.view_assigns["assignment_by_editor"]).to be
      expect(@controller.view_assigns["paused_by_editor"]).to be
    end
  end

  describe "#show" do
    it "assigns the requested editor as @editor" do
      editor = create(:editor)
      get :show, params: {id: editor.to_param}
      expect(@controller.view_assigns["editor"]).to eq(editor)
    end
  end

  describe "#new" do
    it "assigns a new editor as @editor" do
      get :new, params: {}
      expect(@controller.view_assigns["editor"]).to be_a_new(Editor)
    end
  end

  describe "#edit" do
    it "assigns the requested editor as @editor" do
      editor = create(:editor)
      get :edit, params: {id: editor.to_param}
      expect(@controller.view_assigns["editor"]).to eq(editor)
    end
  end

  describe "#create" do
    context "with valid params" do
      it "creates a new Editor" do
        new_editor = build(:editor)
        expect {
          post :create, params: {editor: new_editor.attributes.merge(track_ids: new_editor.track_ids)}
        }.to change(Editor, :count).by(1)
      end

      it "assigns a newly created editor as @editor" do
        new_editor = build(:editor)
        post :create, params: {editor: new_editor.attributes.merge(track_ids: new_editor.track_ids)}
        expect(@controller.view_assigns["editor"]).to be_a(Editor)
        expect(@controller.view_assigns["editor"]).to be_persisted
      end

      it "redirects to the created editor" do
        new_editor = build(:editor)
        post :create, params: {editor: new_editor.attributes.merge(track_ids: new_editor.track_ids)}
        expect(response).to redirect_to(Editor.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved editor as @editor" do
        post :create, params: {editor: {login: nil}}
        expect(@controller.view_assigns["editor"]).to be_a_new(Editor)
      end

      it "goes back to the 'new' form" do
        editor_count = Editor.count
        post :create, params: {editor: {login: nil}}

        expect(response).to_not be_redirect
        expect(Editor.count).to eq(editor_count)
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      it "updates the requested editor" do
        editor = create(:editor)
        put :update, params: {id: editor.to_param, editor: {first_name: "Different"}}
        editor.reload
        expect(editor.first_name).to eql("Different")
      end

      it "assigns the requested editor as @editor" do
        editor = create(:editor)
        put :update, params: {id: editor.to_param, editor: {first_name: "Different"}}
        expect(@controller.view_assigns["editor"]).to eq(editor)
      end

      it "redirects to the editor" do
        editor = create(:editor)
        put :update, params: {id: editor.to_param, editor: {first_name: "Different"}}
        expect(response).to redirect_to(editor)
      end
    end

    context "with invalid params" do
      it "assigns the editor as @editor" do
        editor = create(:editor)
        put :update, params: {id: editor.to_param, editor: {login: nil}}
        expect(@controller.view_assigns["editor"]).to eq(editor)
      end

      it "goes back to the 'edit' form" do
        editor = create(:editor)
        editor_login = editor.login
        put :update, params: {id: editor.to_param, editor: {login: nil}}

        expect(response).to_not be_redirect
        expect(editor.reload.login).to eq(editor_login)
      end
    end
  end

  describe "#destroy" do
    it "destroys the requested editor" do
      editor = create(:editor)
      expect {
        delete :destroy, params: {id: editor.to_param}
      }.to change(Editor, :count).by(-1)
    end

    it "redirects to the editors list" do
      editor = create(:editor)
      delete :destroy, params: {id: editor.to_param}
      expect(response).to redirect_to(editors_url)
    end
  end

  describe "#lookup" do
    it "returns nil orcid if no associated user" do
      editor = create(:editor)
      get :lookup, params: {login: editor.login }

      expect(JSON.parse(response.body)['name']).to eq('Person McEditor')
      expect(JSON.parse(response.body)['url']).to eq('http://placekitten.com')
      expect(JSON.parse(response.body)['orcid']).to eq(nil)
    end

    it "includes editor's user orcid" do
      editor = create(:editor, user: create(:user))

      get :lookup, params: {login: editor.login }

      expect(JSON.parse(response.body)['name']).to eq('Person McEditor')
      expect(JSON.parse(response.body)['url']).to eq('http://placekitten.com')
      expect(JSON.parse(response.body)['orcid']).to eq('0000-0000-0000-1234')
    end
  end
end
