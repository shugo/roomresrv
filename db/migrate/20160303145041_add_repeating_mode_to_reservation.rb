class AddRepeatingModeToReservation < ActiveRecord::Migration
  def change
    add_column :reservations, :repeating_mode, :integer, default: 0, null: false
  end
end
