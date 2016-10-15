class CreateReservationCancels < ActiveRecord::Migration[5.0]
  def change
    create_table :reservation_cancels do |t|
      t.references :reservation, foreign_key: true
      t.date :start_on, null: false

      t.timestamps
    end
  end
end
