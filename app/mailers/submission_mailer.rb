class SubmissionMailer < ApplicationMailer
  def submitted(submission_id)
    @submission = Submission.includes(form: [:user]).where(id: submission_id).take!
    @form = @submission.form
    @user = @form.user
    if @form.email?
      mail(to: @user.email, subject: "New Submission for #{@form.name}")
    end
  end
end
