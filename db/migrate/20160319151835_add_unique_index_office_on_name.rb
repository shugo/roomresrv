class AddUniqueIndexOfficeOnName < ActiveRecord::Migration[4.2]
  def change
    add_index :offices, :name, unique: true
  end
end
