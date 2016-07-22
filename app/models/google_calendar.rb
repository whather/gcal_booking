require 'google/apis/calendar_v3'

class GoogleCalendar
  attr_reader :service, :user

  def initialize(user, auth_client)
    @user = user
    @service = load_service(auth_client)
  end

  def calendar_list
    service.list_calendar_lists
  end

  def calendar(calendar_id = user.email)
    service.get_calendar_list(calendar_id)
  end

  def events(calendar_id = user.email)
    service.list_events(calendar_id)
  end

  private

  def load_service(auth_client)
    s = Google::Apis::CalendarV3::CalendarService.new
    s.client_options.application_name = 'GcalBooking'
    s.authorization = auth_client
    s
  end
end
