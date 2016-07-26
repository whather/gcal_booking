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

    if google_resource_state == "exists"
      logger.info "exists callback"

      channel = GoogleChannel.find_by(channel_id: google_channel_id)
      handler = GoogleCallbackHandler.new(channel)
      handler.call
    end

    head :ok
  end
end
