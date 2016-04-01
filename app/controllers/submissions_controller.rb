class SubmissionsController < ApplicationController
  before_action :authorize, except: :create
  skip_before_action :verify_authenticity_token, only: :create

  def index
    @form = current_user.forms.where(id: params[:form_id]).take!
    @submissions = @form.submissions.limit(5)
  end
  
  def show
    @submission = current_user.submissions.includes(:form).where(id: params[:id]).take!
    @form = @submission.form
  end

  # this is a special case action that isn't authenticated
  # but instead works off of knowning the form's uid
  def create
    form = Form.where(uid: params[:form_uid]).take!

    form.submissions.create!(payload: safe_params.to_h)

    if form.redirect_url?
      redirect_to form.redirect_url
    else
      redirect_to thanks_url
    end
  end

  def destroy
    submission = current_user.submissions.includes(:form).where(id: params[:id]).take!

    submission.destroy!

    redirect_to form_submissions_url(submission.form)
  end

  private

  def safe_params
    params.except(:controller, :action, :form_uid).permit!
  end
end
