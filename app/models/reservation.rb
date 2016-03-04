class Reservation < ActiveRecord::Base
  belongs_to :room
  validates :representative, presence: true
  validates :purpose, presence: true
  validates :num_participants, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validate :check_schedule_conflict

  REPEATING_MODES = {
    0 => "なし",
    1 => "毎週",
    2 => "毎月"
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
    if start_at > end_at
      errors.add(:end_at, "は開始日時より前の日時です")
    end
  end
end
