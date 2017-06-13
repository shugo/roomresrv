class AddNotNullToOffice < ActiveRecord::Migration[4.2]
  def change
    change_column :offices, :name, :string, null: false
  end
end
