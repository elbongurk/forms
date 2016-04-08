# Preview all emails at http://localhost:3000/rails/mailers/submission_mailer
class SubmissionMailerPreview < ActionMailer::Preview
  def submitted
    SubmissionMailer.submitted(Submission.first.id)
  end
end
