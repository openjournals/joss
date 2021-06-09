class OnboardingsController < ApplicationController
  before_action :require_user, only: [:editor]
  before_action :require_admin_user, except: [:editor]

  def editor
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

  def onboarding_invitation_params
    params.require(:onboarding_invitation).permit(:email, :name)
  end
end
