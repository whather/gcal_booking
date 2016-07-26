module GcalHandlable
  extend ActiveSupport::Concern

  def google_resource_state
    request.headers["HTTP_X_GOOG_RESOURCE_STATE"]
  end

  def google_resource_id
    request.headers["HTTP_X_GOOG_RESOURCE_ID"]
  end

  def google_channel_id
    request.headers["HTTP_X_GOOG_CHANNEL_ID"]
  end

  def google_expiration
    Time.parse(raw_google_expiration).localtime
  end

  # for redis(ActiveJob)
  def google_attributes
    {
      resource_state: google_resource_state,
      resource_id:    google_resource_id,
      channel_id:     google_channel_id,
      expired_at:     google_expiration,
    }
  end

  private

  def raw_google_expiration
    headers["HTTP_X_GOOG_CHANNEL_EXPIRATION"]
  end
end
