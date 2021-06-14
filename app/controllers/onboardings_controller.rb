class OnboardingsController < ApplicationController
  before_action :require_admin_user, except: [:editor, :add_editor]
  before_action :require_user, only: [:editor, :add_editor]
  before_action :check_invited_editor, only: [:editor, :add_editor]
  before_action :load_editor, only: [:editor, :add_editor]

  def editor
  end

  def add_editor
    if @editor.update(new_editor_params)
      flash[:notice] = "Thanks! An editor in chief will review your info soon"
    else
      flash[:error] = "Error saving your data: All fields are mandatory"
    end
    redirect_to editor_onboardings_path(@onboarding.token)
  end

  def index
    @onboardings = OnboardingInvitation.all.order(last_sent_at: :desc)
    @pending_editors = Editor.pending
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
      flash[:notice] = "#{editor.full_name} (#{editor.login}) accepted as topic editor!"
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

  private

  def check_invited_editor
    unless @onboarding = OnboardingInvitation.find_by(token: params[:token], email: current_user.email)
      flash[:error] = "The page you requested is not available"
      redirect_to root_path
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
    params.require(:editor).permit(:first_name, :last_name, :login, :email).merge(kind: "pending")
  end
end
