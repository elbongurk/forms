class FormsController < ApplicationController
  before_action :require_authorization

  def index
    @forms = current_user.forms
  end

  def show
    @form = current_user.forms.where(id: params[:id]).take!
    @submissions = @form.submissions.where(spam: false).limit(5)
  end

  def new
    @form = current_user.forms.new
  end

  def create
    @form = current_user.forms.new(safe_params)
    if @form.save
      redirect_to form_url(@form)
    else
      render action: :new
    end
  end

  def edit
    @form = current_user.forms.where(id: params[:id]).take!
  end

  def update
    @form = current_user.forms.where(id: params[:id]).take!
    if @form.update(safe_params)
      redirect_to form_url(@form)
    else
      render action: :edit
    end
  end

  def destroy
    form = current_user.forms.where(id: params[:id]).take!

    form.destroy!

    redirect_to forms_url
  end

  private

  def safe_params
    params.require(:form).permit(:name, :redirect_url, :email)
  end
end
