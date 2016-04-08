class SubmissionMailer < ApplicationMailer
  def submitted(submission)
    @submission = submission
    @form = @submission.form
    @user = @form.user
    if @form.email?
      mail(to: @user.email, subject: "New Submission for #{@form.name}")
    end
  end
end
