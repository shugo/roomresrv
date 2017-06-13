class AddRepeatingModeToReservation < ActiveRecord::Migration[4.2]
  def change
    add_column :reservations, :repeating_mode, :integer, default: 0, null: false
  end
end
