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
    if conflict_with_no_repeat_reservations? ||
      conflict_with_weekly_reservations?
      errors.add(:start_at, "は他の予約と重なっています")
      errors.add(:end_at, "は他の予約と重なっています")
    end
    if start_at && start_at > end_at
      errors.add(:end_at, "は開始日時より前の日時です")
    end
  end

  def conflict_with_no_repeat_reservations?
    reservations = Reservation.no_repeat.where(
      "room_id = ? AND start_at < ? AND end_at > ?",
      room_id, end_at, start_at
    )
    unless new_record?
      reservations = reservations.where("NOT id = ?", id)
    end
    !reservations.first.nil?
  end

  def conflict_with_weekly_reservations?
    reservations = Reservation.includes(:reservation_cancels).
      weekly.where(room_id: room_id)
    unless new_record?
      reservations = reservations.where("NOT id = ?", id)
    end
    reservations.flat_map { |r|
      r.repeat_weekly(start_at.ago(7.days), end_at.since(7.days))
    }.any? { |r|
      r[:start_at] < end_at && r[:end_at] > start_at
    }
  end

  def repeat_weekly(start_time, end_time)
    offset = start_at.wday - start_time.wday
    if offset < 0
      offset += 7
    end
    a = []
    t = start_time.beginning_of_day + offset.days +
      (start_at - start_at.beginning_of_day)
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
