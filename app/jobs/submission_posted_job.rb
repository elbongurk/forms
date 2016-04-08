class SubmissionPostedJob < ApplicationJob
  def perform(submission)
    submission.check!
    if submission.ham? && submission.form.email?
      SubmissionMailer.submitted(submission).deliver_later
    end
  end
end
