class GoogleCalendarsController < ApplicationController
  before_action :authenticate_user!

  def index
    unless current_user.refresh_token?
      redirect_to google_authorize_path and return
    end

    auth = GoogleAuthorizer.new
    auth.update_token!(current_user)
    gcal = GoogleCalendar.new(current_user, auth.auth_client)
    @calendars = gcal.calendar_list.items
  end
end
