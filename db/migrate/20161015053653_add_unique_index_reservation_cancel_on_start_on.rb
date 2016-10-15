class AddUniqueIndexReservationCancelOnStartOn < ActiveRecord::Migration[5.0]
  def change
    add_index :reservation_cancels, [:reservation_id, :start_on], unique: true
  end
end
