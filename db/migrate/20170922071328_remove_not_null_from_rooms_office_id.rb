class RemoveNotNullFromRoomsOfficeId < ActiveRecord::Migration[5.1]
  def change
    change_column_null :rooms, :office_id, true
  end
end
