class GoogleEventHandler
  attr_reader :event, :cb_handler, :slashed_attrs

  delegate :channel, :room, to: :cb_handler

  def initialize(event_item, callback_handler)
    @event = event_item
    @cb_handler = callback_handler
    @slashed_attrs = GoogleEventAttributes.new(@event).call
  end

  def call
    Rails.logger.info "GoogleEventHandler#call"
    Rails.logger.info event.to_h

    # [{ start_at: start_at, end_at: end_at }]
    if deleting?
      Rails.logger.info "deleted event"
      Rails.logger.info event.to_h
      bookings.each { |b| b.try(:destroy!) }
      return true
    end

    unless bookings.empty?
      bookings.delete_all
    end

    slashed_attributes.each do |attr|
      st = attr[:start_at]
      ed = attr[:end_at]
      next if room.bookings.in_between(st, ed).exists?

      room.bookings.create!(
        start_at: st,
        end_at: ed,
        google_resource_id: event.id
      )
    end
  end

  private

  def bookings
    @bookings ||= room.bookings.where(google_resource_id: event.id)
  end

  def deleting?
    event.status == "canceled" && start_at.nil? && end_at.nil?
  end

  def start_at
    event.start.try(:date_time)
  end

  def end_at
    event.end.try(:date_time)
  end
end
