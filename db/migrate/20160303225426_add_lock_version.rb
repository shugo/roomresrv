class AddLockVersion < ActiveRecord::Migration[4.2]
  def change
    add_column :offices, :lock_version, :integer, default: 0, null: false
    add_column :rooms, :lock_version, :integer, default: 0, null: false
    add_column :reservations, :lock_version, :integer, default: 0, null: false
  end
end
