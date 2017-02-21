json.array!(@reservations) do |reservation|
  json.extract! reservation, :id, :room_id, :representative, :purpose, :num_participants, :start_at, :end_at, :note
  json.url reservation_url(reservation, format: :json)
end
