class AddNotNullToReservation < ActiveRecord::Migration[4.2]
  def change
    change_column :reservations, :room_id, :integer, null: false
    change_column :reservations, :representative, :string, null: false
    change_column :reservations, :purpose, :string, null: false
    change_column :reservations, :start_at, :datetime, null: false
    change_column :reservations, :end_at, :datetime, null: false
  end
end
