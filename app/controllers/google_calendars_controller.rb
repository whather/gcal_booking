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

    logger.info  "[INFO] logging start for /google_calendars/callback: #{google_resource_state}"

    case google_resource_state
    when "exists"
      # use next_sync_token
      # get event list
      # compare with bookings
      # and create, update or delete event
      logger.info "exists callback"

      load_google_channel

      head :ok and return if @google_channel.nil? || @room.nil? || @user.nil?

      ga = google_authorizer(@user)
      cal = GoogleCalendar.new(@user, ga.auth_client)
      events = cal.events(@google_channel.calendar_id, sync_token: @google_channel.next_sync_token)
      @google_channel.update!(next_sync_token: events.next_sync_token)

      events.items.each do |e|
        if e.created == e.updated
          # create resource (company booking)
          if !e.end_time_unspecified? &&
             !@google_channel.room.bookings.in_between(e.start.date_time, e.end.date_time).exists?
            @google_channel.room.bookings.create!(
              start_at: e.start.date_time,
              end_at: e.end.date_time,
              google_resource_id: e.id
            )
          end
        else
          # update / delete
          booking = @room.bookings.find_by(google_resource_id: e.id)
          if booking
            if e.start.nil? || e.end.nil?
              booking.destroy
            else
              booking.update!(start_at: e.start.date_time, end_at: e.end.date_time)
            end
          else
            if e.summary =~ /^【自社】/
              # create company booking record
            else
              # delete the event
            end
          end
        end
        # e.id # resource_id
        # # e.status # confirmed, tentative, canceled
        # e.summary # title
        # e.recurrence # Array[String] parse, resolve and apply
        # e.recurring_event_id
        # e.created, e.updated
        # e.visibility # default, public, private, (confidential)
      end

    when "not_exists"
      # stop watching
      logger.info "not_exists callback"
    end

    head :ok
  end

  private

  def load_google_channel
    @google_channel = GoogleChannel.find_by(channel_id: google_channel_id)

    return unless @google_channel

    @room = @google_channel.room
    @user = @google_channel.room.user
  end
end
