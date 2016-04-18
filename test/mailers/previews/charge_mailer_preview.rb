# Preview all emails at http://localhost:3000/rails/mailers/charge_mailer
class ChargeMailerPreview < ActionMailer::Preview
  def paid
    ChargeMailer.paid(Charge.first)
  end
end
