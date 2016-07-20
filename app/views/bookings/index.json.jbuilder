json.array!(@bookings) do |booking|
  json.extract! booking, :id, :room_id, :start_at, :end_at
  json.url booking_url(booking, format: :json)
end
