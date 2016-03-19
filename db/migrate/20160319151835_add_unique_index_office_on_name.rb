class AddUniqueIndexOfficeOnName < ActiveRecord::Migration
  def change
    add_index :offices, :name, unique: true
  end
end
