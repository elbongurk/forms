class SubmissionPostedJob < ApplicationJob
  def perform(submission_id, *options)
    submission = Submission.includes(:form).where(id: submission_id).take!

    submission.check!
    
    if submission.ham? && submission.form.email?
      SubmissionMailer.submitted(submission_id).deliver_later
    end
  end
end
