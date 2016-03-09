class ChangeNumParticipantsToString < ActiveRecord::Migration
  def change
    change_column :reservations, :num_participants, :string
  end
end
