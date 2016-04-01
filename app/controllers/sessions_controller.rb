class SessionsController < ApplicationController
  def new
    @session = Session.new
  end

  def create
    @session = Session.new(session_params)
    if user = @session.authenticate
      sign_in user
      redirect_back_or root_url
    else
      flash.now[:error] = "Bad email or password"
      render action: :new, status: :unauthorized
    end
  end

  def destroy
    sign_out
    redirect_to sign_in_url
  end
  
  private
  
  def session_params
    params.require(:session).permit(:email, :password)
  end
end
