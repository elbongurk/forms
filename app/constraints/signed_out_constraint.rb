class SignedOutConstraint
  def matches?(request)
    request.session[:user_id].blank?
  end
end
