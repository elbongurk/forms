class FormsController < ApplicationController
  before_action :require_subscription

  def index
    @user = current_user

    @forms = current_user.forms.order(created_at: :desc)
    @submission_count = current_user.submissions.ham.group(:form_id).count
    @submission_last = current_user.submissions.ham.group(:form_id).maximum(:created_at)
  end

  def show
    @form = current_user.forms.where(id: params[:id]).take!
    @submissions = @form.submissions.ham.limit(5).order(created_at: :desc)
  end

  def new
    if current_user.form_quota_met?
      redirect_to forms_url
    else
      @form = current_user.forms.new
    end
  end

  def create
    if current_user.form_quota_met?
      redirect_to forms_url
    else
      @form = current_user.forms.new(safe_params)
      if @form.save
        redirect_to form_url(@form)
      else
        render action: :new
      end
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
    params.require(:form).permit(:name, :redirect_url, :email, :additional_emails)
  end
end
