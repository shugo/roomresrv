class InsertScheduleRoom < ActiveRecord::Migration[5.1]
  def up
    Room.create!(id: 0, name: "予定")
  end

  def down
    Room.find(0).destroy!
  end
end
