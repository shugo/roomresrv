class AddNotNullToOffice < ActiveRecord::Migration
  def change
    change_column :offices, :name, :string, null: false
  end
end
