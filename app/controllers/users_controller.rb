class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(create_params)
    if @user.save
      sign_in @user
      redirect_to root_url
    else
      render action: :new
    end
  end

  private

  def create_params
    params.require(:user).permit(:name, :email, :password)
  end
end
