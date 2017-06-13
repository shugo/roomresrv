class DeprecateMonthlyReservations < ActiveRecord::Migration[4.2]
  def up
    Reservation.where(repeating_mode: 2).update_all(repeating_mode: 0)
  end
end
