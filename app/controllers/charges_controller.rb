class ChargesController < ApplicationController
  before_action :require_authorization

  def index
    @user = current_user
    @charges = current_user.charges
  end
end
