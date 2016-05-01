class SubmissionMailer < ApplicationMailer
  def submitted(submission)
    @submission = submission
    @form = @submission.form
    @user = @form.user

    to = @form.additional_emails
    if @form.email?
      to << @user.email
    end
    
    if to.present?
      mail(to: to, subject: "New Submission for #{@form.name}")
    end
  end
end
