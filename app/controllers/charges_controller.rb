class ChargesController < ApplicationController
  before_action :require_authorization

  def index
    @charges = current_user.charges
  end
end
