class DeprecateMonthlyReservations < ActiveRecord::Migration
  def up
    Reservation.where(repeating_mode: 2).update_all(repeating_mode: 0)
  end
end
