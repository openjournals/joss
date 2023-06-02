class OnboardingsController < ApplicationController
  before_action :require_aeic, except: [:editor, :add_editor]
  before_action :require_user, only: [:editor, :add_editor]
  before_action :check_invited_editor, only: [:editor, :add_editor]
  before_action :load_editor, only: [:editor, :add_editor]

  def editor
  end

  def add_editor
    if @editor.update(new_editor_params)
      @onboarding.accepted!(@editor)
      flash[:notice] = "Thanks! An editor in chief will review your info soon"
      redirect_to root_path
    else
      if JournalFeatures.tracks?
        flash[:error] = "Error saving your data: Name, Email, GitHub username and Tracks are mandatory"
      else
        flash[:error] = "Error saving your data: Name, Email and GitHub username are mandatory"
      end

      redirect_to editor_onboardings_path(@onboarding.token)
    end
  end

  def index
    @onboardings = OnboardingInvitation.pending_acceptance.order(last_sent_at: :desc)
    @pending_editors = Editor.includes(:onboarding_invitation).pending
  end

  def create
    onboarding = OnboardingInvitation.new(onboarding_invitation_params)
    if onboarding.save
      flash[:notice] = "Invitation to join the editorial team sent"
    else
      flash[:error] = onboarding.errors.full_messages.first
    end
    redirect_to onboardings_path
  end

  def accept_editor
    if editor = Editor.find(params[:editor_id])
      editor.accept!
      flash[:notice] = "#{editor.full_name} (@#{editor.login}) accepted as topic editor!"
    end
    redirect_to onboardings_path
  end

  def resend_invitation
    if onboarding = OnboardingInvitation.find(params[:id])
      onboarding.send_email
      flash[:notice] = "Email sent again"
    end
    redirect_to onboardings_path
  end

  def destroy
    if onboarding = OnboardingInvitation.find(params[:id])
      onboarding.destroy!
      flash[:notice] = "Onboarding invitation deleted"
    end
    redirect_to onboardings_path
  end

  def invite_to_editors_team
    editor = Editor.find(params[:editor_id])
    if editor && Repository.invite_to_editors_team(editor.login)
      editor.onboarding_invitation.invited_to_team!
      flash[:notice] = "@#{editor.login} invited to GitHub Open Journals' editors team"
    else
      flash[:error] = "Failure sending GitHub invitation"
    end
    redirect_to onboardings_path
  end

  private

  def check_invited_editor
    unless @onboarding = OnboardingInvitation.find_by(token: params[:token], email: current_user.email)
      flash[:error] = "The page you requested is not available"
      redirect_to(root_path) and return
    end

    unless !current_user.editor? || current_user.editor.pending?
      flash[:error] = "You already are an editor"
      redirect_to root_path
    end
  end

  def load_editor
    @editor = current_user.editor || Editor.new(user: current_user, kind: "pending")
  end

  def onboarding_invitation_params
    params.require(:onboarding_invitation).permit(:email, :name)
  end

  def new_editor_params
    params.require(:editor).permit(:first_name, :last_name, :login, :email, :category_list, :url, :description, { track_ids: [] }).merge(kind: "pending")
  end
end
