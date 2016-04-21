class UsersController < ApplicationController
  before_action :require_no_authorization, except: [:edit, :update]
  before_action :require_authorization, only: [:edit, :update]

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(update_params)
      flash[:success] = "Profile updated"
      redirect_to root_url
    else
      render action: :edit
    end
  end
  
  def new
    @user = User.new
    @plan = Plan.unarchived.find_by_name_or_default(params[:plan])
  end

  def create
    @user = User.new(create_params)
    @plan = Plan.unarchived.find_by_name_or_default(params[:plan])
    if @user.save
      @user.subscriptions.create_trial_for_plan(@plan)
      sign_in @user
      redirect_to root_url
    else
      render action: :new
    end
  end

  private

  def create_params
    params.require(:user).permit(:email, :password)
  end

  def update_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
