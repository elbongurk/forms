class SubmissionsController < ApplicationController
  before_action :require_subscription, except: :create
  skip_before_action :verify_authenticity_token, only: :create

  def index
    @form = current_user.forms.where(id: params[:form_id]).take!
    @submissions = @form.submissions.ham.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.csv { send_data @submissions.to_csv, type: Mime::CSV }
    end
  end
  
  def show
    @submission = current_user.submissions.includes(:form).where(id: params[:id]).take!
    @form = @submission.form
  end

  def create
    form = Form.where(uid: params[:form_uid]).take!

    submission = form.submissions.create!(payload: safe_params, headers: safe_headers)

    SubmissionPostedJob.perform_later submission

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
    params.except(:controller, :action, :form_uid).permit!.to_h
  end

  def safe_headers
    request.headers.select { |k,v| k =~ /^HTTP_/ }.reject { |k,v| 'HTTP_COOKIE' == k }.to_h
  end
end
