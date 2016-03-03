class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.references :room, index: true, foreign_key: true
      t.string :representative
      t.string :purpose
      t.integer :num_participants
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps null: false
    end
  end
end
