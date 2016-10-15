class Reservation < ApplicationRecord
  belongs_to :room
  has_many :reservation_cancels, dependent: :delete_all

  enum repeating_mode: { no_repeat: 0, weekly: 1 }

  validates :room_id, presence: true
  validates :representative, presence: true
  validates :purpose, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :repeating_mode, presence: true
  validate :check_schedule_conflict

  REPEATING_MODE_LABELS = {
    "no_repeat" => "なし",
    "weekly" => "毎週"
  }

  def check_schedule_conflict
    reservations = Reservation.where(
      "room_id = ? AND start_at < ? AND end_at > ?",
      room_id, end_at, start_at
    )
    unless new_record?
      reservations = reservations.where("NOT id = ?", id)
    end
    if reservations.first
      errors.add(:start_at, "は他の予約と重なっています")
      errors.add(:end_at, "は他の予約と重なっています")
    end
    if start_at && start_at > end_at
      errors.add(:end_at, "は開始日時より前の日時です")
    end
  end

  def repeat_weekly(start_time, end_time)
    offset = start_at.wday - start_time.wday
    if offset < 0
      offset += 7
    end
    a = []
    t = start_time + offset.days + (start_at - start_at.beginning_of_day)
    canceled_dates = reservation_cancels.map { |cancel|
      cancel.start_on
    }
    while t < end_time
      if t >= start_at && !canceled_dates.include?(t.to_date)
        a << { start_at: t, end_at: end_at + (t - start_at) }
      end
      t += 7.days
    end
    a
  end
end
