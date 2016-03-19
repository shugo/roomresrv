class AddUniqueIndexRoomOnOfficeIdAndName < ActiveRecord::Migration
  def change
    add_index :rooms, [:office_id, :name], unique: true
  end
end
