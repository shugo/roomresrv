class AddNotNullToRoom < ActiveRecord::Migration[4.2]
  def change
    change_column :rooms, :office_id, :integer, null: false
    change_column :rooms, :name, :string, null: false
  end
end
