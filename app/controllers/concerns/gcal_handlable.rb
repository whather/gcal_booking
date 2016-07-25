module GcalHandlable
  extend ActiveSupport::Concern

  def google_resource_state
    headers["X-Goog-Resource-State"]
  end

  def google_resource_id
    headers["X-Goog-Resource-ID"]
  end

  def google_channel_id
    headers["X-Goog-Channel-ID"]
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
    headers["X-Goog-Channel-Expiration"]
  end
end
