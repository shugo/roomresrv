class AddIndexToReservation < ActiveRecord::Migration
  def change
    add_index :reservations, :start_at, name: "index_reservations_on_start_at"
    add_index :reservations, :end_at, name: "index_reservations_on_end_at"
    add_index :reservations, :repeating_mode,
      name: "index_reservations_on_repeating_mode"
  end
end
