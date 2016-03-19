class AddNotNullToRoom < ActiveRecord::Migration
  def change
    change_column :rooms, :office_id, :integer, null: false
    change_column :rooms, :name, :string, null: false
  end
end
