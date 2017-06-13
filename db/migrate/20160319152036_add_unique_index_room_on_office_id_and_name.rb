class AddUniqueIndexRoomOnOfficeIdAndName < ActiveRecord::Migration[4.2]
  def change
    add_index :rooms, [:office_id, :name], unique: true
  end
end
