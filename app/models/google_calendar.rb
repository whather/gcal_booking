require 'google/apis/calendar_v3'

class GoogleCalendar
  attr_reader :service, :user

  def initialize(user, auth_client)
    @user = user
    @service = load_service(auth_client)
  end

  def calendar_list(options = { min_access_role: 'writer' })
    service.list_calendar_lists(options)
  end

  def calendar(calendar_id = user.email)
    service.get_calendar_list(calendar_id)
  end

  def events(calendar_id = user.email)
    service.list_events(calendar_id)
  end

  # see
  # https://github.com/google/google-api-ruby-client/blob/master/generated/google/apis/calendar_v3/service.rb#L1757
  def watch_events(calendar_id = user.email, options = {})
    channel_id = SecureRandom.uuid
    my_channel = Google::Apis::CalendarV3::Channel.new(
      id: channel_id,
      address: "https://gcal-booking.herokuapp.com/google_calendars/callback",
      type: 'web_hook',
    )
    channel = service.watch_event(calendar_id, my_channel, options)
    Rails.logger.info channel.to_h
    channel
  end

  private

  def load_service(auth_client)
    s = Google::Apis::CalendarV3::CalendarService.new
    s.client_options.application_name = 'GcalBooking'
    s.authorization = auth_client
    s
  end
end
