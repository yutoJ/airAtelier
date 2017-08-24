class ReservationMailer < ApplicationMailer
  def send_email_to_guest(guest)
    @recipient = guest
    mail to: @recipient.email, subject: "Enjoy Your Trip!", from: 'special@yourmail.com'
  end
end
