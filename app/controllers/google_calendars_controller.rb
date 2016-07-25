class GoogleCalendarsController < ApplicationController
  include GcalHandlable

  protect_from_forgery except: [:callback]
  before_action :authenticate_user!, only: [:index]

  def index
    unless current_user.refresh_token?
      redirect_to google_authorize_path and return
    end

    @calendars = calendar_list.items
  end

  def callback
    # TODO: pass the request to ActiveJob
    gc = GoogleChannel.find_by(channel_id: google_channel_id)
    user = gc.room.user
    ga = google_authorizer(user)

    case google_resource_state
    when "sync"
      cal = GoogleCalendar.new(user, ga.auth_client)
      events = cal.events(gc.calendar_id)
      gs.update!(expired_at: google_expiration, next_sync_token: events.next_sync_token)
      logger.info headers
      logger.info headers.to_h rescue nil
      logger.info params
    when "exists"
      # use next_sync_token
      # get event list
      # compare with bookings
      # and create, update or delete event
    when "not_exists"
      # stop watching
    end

    head :ok
  end
end
