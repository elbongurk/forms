class PasswordsController < ApplicationController
  before_action :require_no_authorization
  
  def new
    @password = Password.new
  end

  def create
    @password = Password.new(create_params)

    if @password.reset
      flash[:success] = "Check #{@password.email} to reset your password"
      redirect_to root_url
    else
      render action: :new, status: :unauthorized
    end
  end

  def edit
    @password = Password.new(edit_params)
  end

  def update
    @password = Password.new(update_params)

    if user = @password.update
      sign_in user
      flash[:success] = "Your password has been updated"
      redirect_to root_url
    else
      render action: :edit, status: :unauthorized
    end
  end

  private

  def create_params
    params.require(:password).permit(:email)
  end  
  
  def edit_params
    { password_reset_token: params[:password_reset_token] }
  end
  
  def update_params    
    params.require(:password).permit(:password).merge(edit_params)
  end
end
