class EditorsController < ApplicationController
  # TODO: This is a holdover from before orcid/auth
  # before_action :require_admin_user
  before_action :set_editor, only: [:show, :edit, :update, :destroy]

  def index
    @editors = Editor.all
  end

  def show
  end

  def new
    @editor = Editor.new
  end

  def edit
  end

  def create
    @editor = Editor.new(editor_params)

    if @editor.save
      redirect_to @editor, notice: 'Editor was successfully created.'
    else
      render :new
    end
  end

  def update
    if @editor.update(editor_params)
      redirect_to @editor, notice: 'Editor was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @editor.destroy
    redirect_to editors_url, notice: 'Editor was successfully destroyed.'
  end

  private
    def set_editor
      @editor = Editor.find(params[:id])
    end

    def editor_params
      params.require(:editor).permit(:kind, :title, :first_name, :last_name, :login, :email, :avatar_url, :category_list, :url, :description)
    end
end
