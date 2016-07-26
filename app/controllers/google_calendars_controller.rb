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

  # ignore `state` request
  def callback
    # TODO: pass the request to ActiveJob
    # gc = GoogleChannel.find_by(channel_id: google_channel_id)
    # user = gc.room.user
    # ga = google_authorizer(user)

    logger.info  "[INFO]  logging start for /google_calendars/callback"
    logger.info  google_resource_state

    logger.info "X-Goog-Resource-State: #{request.headers['X-Goog-Resource-State']}"
    logger.info "X-GOOG-RESOURCE-STATE: #{request.headers['X-GOOG-RESOURCE-STATE']}"
    logger.info "X_GOOG_RESOURCE_STATE: #{request.headers['X_GOOG_RESOURCE_STATE']}"

    logger.info "Http-X-Goog-Resource-State: #{request.headers['Http-X-Goog-Resource-State']}"
    logger.info "HTTP-X-GOOG-RESOURCE-STATE: #{request.headers['HTTP-X-GOOG-RESOURCE-STATE']}"
    logger.info "HTTP_X_GOOG_RESOURCE_STATE: #{request.headers['HTTP_X_GOOG_RESOURCE_STATE']}"

    request.headers.map { |k, v| k =~ /GOOG/ ? logger.info("#{k}: #{v}") : nil }

    case google_resource_state
    when "exists"
      # use next_sync_token
      # get event list
      # compare with bookings
      # and create, update or delete event
      logger.info "exists callback"

      # gc = GoogleChannel.find_by(channel_id: google_channel_id)
      # user = gc.room.user
      # ga = google_authorizer(user)
      # cal = GoogleCalendar.new(user, ga.auth_client)
      # events = cal.events(gc.calendar_id, sync_token: gc.next_sync_token)
      # gc.update!(next_sync_token: events.next_sync_token)
      # events.items.each do |e|
      #   if created == updated
      #     # create resource(alian_booking)
      #   else
      #     # update / delete
      #   end
      #   e.id # resource_id
      #   e.start # e.original_start_time
      #   e.end unless e.end_time_unspecified?
      #   # e.status # confirmed, tentative, canceled
      #   e.summary # title
      #   e.recurrence # Array[String] parse, resolve and apply
      #   e.recurring_event_id
      #   e.created, e.updated
      #   e.visibility # default, public, private, (confidential)
      # end

    when "not_exists"
      # stop watching
      logger.info "not_exists callback"
    end

    head :ok
  end
end
