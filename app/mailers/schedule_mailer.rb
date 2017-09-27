class ScheduleMailer < ApplicationMailer
  def schedule_mail(reservation)
    @reservation = reservation
    start_date = reservation.start_at.strftime("%m/%d")
    end_date = reservation.end_at.strftime("%m/%d")
    if start_date == end_date
      date = start_date
    else
      date = start_date + "〜" + end_date
    end
    subject = "#{reservation.representative}予定(#{date})"
    mail(to: ENV["SCHEDULE_EMAIL_ADDRESS"], subject: subject)
  end
end
