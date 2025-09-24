class ReviewersController < ApplicationController
  before_action :require_admin, except: [:index, :show]
  before_action :set_reviewer, only: [:show, :edit, :update, :destroy]

  def index
    @reviewers = Reviewer.order(:github_username).page(params[:page])
  end

  def show
  end

  def new
    @reviewer = Reviewer.new
  end

  def edit
  end

  def create
    @reviewer = Reviewer.new(reviewer_params)

    if @reviewer.save
      redirect_to @reviewer, notice: 'Reviewer was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @reviewer.update(reviewer_params)
      redirect_to @reviewer, notice: 'Reviewer was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reviewer.destroy
    redirect_to reviewers_url, notice: 'Reviewer was successfully removed.'
  end

  private

  def set_reviewer
    @reviewer = Reviewer.find(params[:id])
  end

  def reviewer_params
    params.require(:reviewer).permit(:github_username, :name, :email, :user_id)
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: 'You must be an admin to access this page.'
    end
  end
end
