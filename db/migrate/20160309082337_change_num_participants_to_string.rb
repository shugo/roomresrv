class ChangeNumParticipantsToString < ActiveRecord::Migration[4.2]
  def change
    change_column :reservations, :num_participants, :string
  end
end
