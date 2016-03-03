json.array!(@rooms) do |room|
  json.extract! room, :id, :office_id, :name
  json.url room_url(room, format: :json)
end
