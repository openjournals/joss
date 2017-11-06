require 'rails_helper'

RSpec.describe EditorsController, type: :controller do
  let(:valid_attributes) do
    []
  end

  let(:invalid_attributes) do
    []
  end

  let(:current_user) { create(:user) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe "#index" do
    it "assigns all editors as @editors" do
      editor = create(:editor)
      get :index
      expect(assigns(:editors)).to eq([editor])
    end
  end

  describe "#show" do
    it "assigns the requested editor as @editor" do
      editor = create(:editor)
      get :show, {:id => editor.to_param}
      expect(assigns(:editor)).to eq(editor)
    end
  end

  describe "#new" do
    it "assigns a new editor as @editor" do
      get :new, {}
      expect(assigns(:editor)).to be_a_new(Editor)
    end
  end

  describe "#edit" do
    it "assigns the requested editor as @editor" do
      editor = create(:editor)
      get :edit, {:id => editor.to_param}
      expect(assigns(:editor)).to eq(editor)
    end
  end

  describe "#create" do
    context "with valid params" do
      it "creates a new Editor" do
        expect {
          post :create, {:editor => build(:editor).attributes}
        }.to change(Editor, :count).by(1)
      end

      it "assigns a newly created editor as @editor" do
        post :create, {:editor => build(:editor).attributes}
        expect(assigns(:editor)).to be_a(Editor)
        expect(assigns(:editor)).to be_persisted
      end

      it "redirects to the created editor" do
        post :create, {:editor => build(:editor).attributes}
        expect(response).to redirect_to(Editor.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved editor as @editor" do
        post :create, {:editor => {login: nil}}
        expect(assigns(:editor)).to be_a_new(Editor)
      end

      it "re-renders the 'new' template" do
        post :create, {:editor => {login: nil}}
        expect(response).to render_template("new")
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      it "updates the requested editor" do
        editor = create(:editor)
        put :update, {:id => editor.to_param, :editor => {first_name: "Different"}}
        editor.reload
        expect(editor.first_name).to eql("Different")
      end

      it "assigns the requested editor as @editor" do
        editor = create(:editor)
        put :update, {:id => editor.to_param, :editor => {first_name: "Different"}}
        expect(assigns(:editor)).to eq(editor)
      end

      it "redirects to the editor" do
        editor = create(:editor)
        put :update, {:id => editor.to_param, :editor => {first_name: "Different"}}
        expect(response).to redirect_to(editor)
      end
    end

    context "with invalid params" do
      it "assigns the editor as @editor" do
        editor = create(:editor)
        put :update, {:id => editor.to_param, :editor => {login: nil}}
        expect(assigns(:editor)).to eq(editor)
      end

      it "re-renders the 'edit' template" do
        editor = create(:editor)
        put :update, {:id => editor.to_param, :editor => {login: nil}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "#destroy" do
    it "destroys the requested editor" do
      editor = create(:editor)
      expect {
        delete :destroy, {:id => editor.to_param}
      }.to change(Editor, :count).by(-1)
    end

    it "redirects to the editors list" do
      editor = create(:editor)
      delete :destroy, {:id => editor.to_param}
      expect(response).to redirect_to(editors_url)
    end
  end
end
