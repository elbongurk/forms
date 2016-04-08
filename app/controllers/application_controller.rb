class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :signed_in?, :signed_out?

  protected

  def handle_unverified_request
    sign_out
    super
  end

  def require_authorization
    unless signed_in?
      deny_access
    end
  end

  def require_no_authorization
    unless signed_out?
      redirect_back(fallback_location: root_url)
    end
  end

  def signed_in?
    current_user.present?
  end

  def signed_out?
    !signed_in?
  end

  def sign_out
    session[:user_id] = nil
  end

  def sign_in(user)
    if user.present?
      session[:user_id] = user.id
    end
  end

  def current_user
    if @current_user.nil? && session[:user_id].present?
      @current_user = User.where(id: session[:user_id]).take
    end
    @current_user
  end

  def deny_access(flash_message=nil)
    store_location

    if flash_message
      flash[:notice] = flash_message
    end

    if signed_in?
      redirect_to root_url
    else
      redirect_to sign_in_url
    end
  end

  private

  def store_location
    if request.get?
      session[:return_to] = request.fullpath
    end
  end

  def redirect_back_or(default)
    redirect_to(return_to || default)
    clear_return_to
  end

  def return_to
    session[:return_to] || params[:return_to]
  end

  def clear_return_to
    session[:return_to] = nil
  end
end
