class GoogleEventHandler
  attr_reader :event, :cb_handler

  delegate :channel, :room, to: :cb_handler

  ## Google::Apis::CalendarV3::Event
  # e.id                 # resource_id
  # e.status             # confirmed, tentative, canceled
  # e.summary            # title
  # e.recurrence         # Array[String] parse, resolve and apply
  # e.recurring_event_id
  # e.created
  # e.updated
  # e.visibility         # default, public, private, (confidential)

  def initialize(event, callback_handler)
    @event = event
    @cb_handler = callback_handler
  end

  def call
    Rails.logger.info "GoogleEventHandler#call"
    Rails.logger.info event.to_h

    if (event.created == event.updated || booking.nil?) &&
       (valid_time_attributes? && !room.bookings.in_between(start_at, end_at).exists?)
      room.bookings.create!(
        start_at: start_at,
        end_at: end_at,
        google_resource_id: event.id
      )
      return true
    end

    if valid_time_attributes?
      booking.update!(start_at: start_at, end_at: end_at)
      return true
    end

    Rails.logger.info "deleted event"
    Rails.logger.info event.to_h
    booking.try(:destroy)
  end

  def valid_time_attributes?
    !event.end_time_unspecified? && start_at && end_at
  end

  private

  def booking
    @booking ||= room.bookings.find_by(google_resource_id: event.id)
  end

  def start_at
    event.start.try(:date_time)
  end

  def end_at
    event.end.try(:date_time)
  end
end
