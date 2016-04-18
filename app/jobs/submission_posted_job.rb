class SubmissionPostedJob < ApplicationJob
  def perform(submission)
    submission.check!
    if submission.ham? && submission.form.email?
      if submission.form.user.subscriptions.unarchived.exists?
        SubmissionMailer.submitted(submission).deliver_later
      end
    end
  end
end
