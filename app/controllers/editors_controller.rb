class EditorsController < ApplicationController
  before_action :require_admin_user, except: [:lookup, :profile, :update_profile]
  before_action :require_editor, only:[:profile, :update_profile]
  before_action :set_editor, only: [:show, :edit, :update, :destroy]
  before_action :set_current_editor, only: [:profile, :update_profile]

  def index
    @editors = Editor.all
    @assignment_by_editor = Paper.unscoped.in_progress.group(:editor_id).count
    @paused_by_editor = Paper.unscoped.in_progress.where("labels->>'paused' ILIKE '%'").group(:editor_id).count
    @pending_invitations_by_editor = Invitation.pending.group(:editor_id).count
    @pending_invitations = Invitation.includes(:paper).pending
  end

  def show
  end

  def new
    @editor = Editor.new
  end

  def lookup
    editor = Editor.find_by_login(params[:login])
    if editor.url
      url = editor.url
    else
      url = "https://github.com/#{params[:login]}"
    end

    response = {  name: "#{editor.first_name} #{editor.last_name}",
                  url: url }

    render json: response.to_json
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

  def profile
  end

  def update_profile
    if @editor.update(profile_params)
      redirect_to editor_profile_path, notice: 'Editor profile was successfully updated.'
    else
      render :profile
    end
  end

  private
    def set_editor
      @editor = Editor.find(params[:id])
    end

    def set_current_editor
      @editor = current_user.editor
    end

    def editor_params
      params.require(:editor).permit(:max_assignments, :availability_comment, :kind, :title, :first_name, :last_name, :login, :email, :avatar_url, :category_list, :url, :description)
    end

    def profile_params
      params.require(:editor).permit(:max_assignments, :availability_comment, :first_name, :last_name, :email, :avatar_url, :category_list, :url, :description)
    end
end
